---
name: tophat-build-install
description: Find, build, and install mobile artifacts for the current repository through GitHub Actions and Tophat. Use when an agent or model needs to help developers, PMs, or reviewers test in-progress work without stashing local changes, switching branches, building locally, or waiting for a manually shared QA build. Handle requests like "install the latest build from main", "install PR #123 on my simulator", or "build this branch and install it". Infer the current GitHub repository from `git remote -v` or `git remote get-url origin` by default, then canonicalize it with `gh repo view` before artifact lookups. This skill is GitHub Actions only and requires `gh` CLI for build lookup and workflow dispatch.
---

# Tophat Build Install

## Overview

Use this skill to turn a user request into a concrete GitHub Actions artifact install through Tophat for the current repository. The main use cases are:

- developers testing another branch, PR, or commit without stashing work or switching branches
- PMs or reviewers testing pre-merge work early
- reusing an existing artifact when the target commit was already built

This skill supports GitHub Actions artifacts only. Require `gh` for GitHub lookup and workflow dispatch. Do not switch to GitHub MCP, direct REST workarounds, or other artifact providers.

## Gather Inputs

Collect only the missing inputs.

- Platform: `ios` or `android`.
- Repository: derive owner and repo from the current checkout first. Prefer `git remote get-url origin`, then fall back to `git remote -v`. Canonicalize the inferred repo with `gh repo view <owner>/<repo> --json nameWithOwner` before using any Actions API path. Ask only if there is no usable GitHub remote.
- Source selector: branch, PR number, workflow run ID, or explicit artifact ID.
- Workflow: workflow file or workflow name when a new build must be triggered.
- Artifact choice: artifact name when a run publishes multiple artifacts.
- Destination: `simulator` or `device` when the user specifies it or when the build output differs by target.
- Launch arguments: only if the app needs them.

If the user says "latest build", prefer the latest successful existing run for the requested branch instead of forcing a rebuild. If the user says "build", "rebuild", or "trigger", dispatch a new workflow run first.

If the user already supplies an explicit `artifact_id`, you may skip build lookup, but still keep the workflow within the GitHub Actions artifact path.

For requests in the current repository, do not ask for owner or repo unless Git remotes are missing or point somewhere non-GitHub.

Prefer defaulting to the current repository over asking broad clarifying questions.

For device requests, ask for `simulator` vs `device` early if the user did not specify it, because CI signing availability materially changes whether the install can succeed.

## Validate Prerequisites

Before installing, confirm:

- `gh` is authenticated
- Tophat is installed and running
- Tophat exposes the `gha` provider
- the helper scripts in `scripts/` are available from the skill directory

For `destination=device`, also confirm the repository already has a CI workflow that produces a signed device-installable artifact.

Use `/Applications/Tophat.app/Contents/MacOS/tophatctl` as the Tophat CLI path. Require Tophat to be installed and running. Require a GitHub personal access token to already be configured in Tophat's GitHub Actions extension settings. Require the GitHub Actions provider ID `gha` to be present in `tophatctl list providers`. Here, `gha` is Tophat's provider ID for the GitHub Actions extension.

If `gh` is not authenticated, the GitHub PAT is not configured in Tophat, or `gha` is not installed, stop and tell the user what is missing. Do not fall back to GitHub MCP, raw REST calls, or another artifact provider.

For device installs, do not assume local Xcode automatic signing has any effect on CI. CI must already have access to signing assets and the workflow must already be able to produce a signed device build.

## Default Behavior

Use this decision order:

1. Infer `owner/repo` from the current checkout.
2. Canonicalize that repository with `gh repo view` and use `nameWithOwner` for all later GitHub API calls.
3. Determine the target ref or artifact from the user request.
4. If the user gave an explicit artifact ID, install it directly.
5. Otherwise, look for an existing matching artifact before triggering a new build.
6. Trigger a workflow only when no suitable artifact already exists or when the user explicitly asks for a rebuild.

This keeps the skill useful for both developer and PM flows, while minimizing unnecessary builds.

## Resolve The Build

Resolve the user's target into a concrete artifact. Use `gh` when you need to inspect PRs, workflows, runs, or artifacts. Use `scripts/gha.py list-artifacts` when you want the local helper to list non-expired artifacts for the current repo or a chosen selector.

Before calling any Actions artifact endpoint, canonicalize the repository with `gh repo view <repo> --json nameWithOwner,url`. A stale Git remote can still resolve to a different canonical repository on GitHub, and the Actions API must use that canonical `nameWithOwner`.

When using `gh run list --json`, only request fields that `gh` actually supports in the current CLI. For workflow runs, prefer the stable set:

- `databaseId`
- `headBranch`
- `headSha`
- `name`
- `status`
- `conclusion`
- `createdAt`
- `updatedAt`
- `url`
- `workflowDatabaseId`

Do not assume REST field names work in `gh run list --json`. For example, `id`, `head_branch`, and `head_sha` are not valid there.

Do not assume `headRefOid` exists in `gh pr view --json`. When you need a PR head SHA, prefer `gh api repos/<owner>/<repo>/pulls/<number>` and read `head.ref` plus `head.sha`.

Do not request `artifacts` from `gh run view --json`. If you need artifacts for a workflow run, use `scripts/gha.py list-artifacts --run-id <database-id>` or call the artifact API shape directly instead of relying on `gh run view`.

Prefer this fallback order when resolving an artifact:

1. If the user gave an explicit artifact ID, install it directly.
2. If the user gave a workflow run ID, list artifacts and match `artifact.workflow_run.id`.
3. If the user gave a PR number, resolve the PR head branch and head SHA, then list artifacts for that head.
4. If the user gave a branch or commit SHA, list artifacts and match branch and-or SHA.
5. Only inspect workflow runs with `gh run list` when you need workflow metadata to decide whether to trigger a new build.
6. Trigger a workflow only when no matching non-expired artifact exists or the user explicitly asked for a rebuild.

`scripts/gha.py list-artifacts` supports these selectors:

- `--ref <branch>`
- `--sha <commit-or-prefix>`
- `--pr <number>`
- `--run-id <database-id>`
- `--platform ios|android`

The helper must be treated as the authoritative artifact fallback because it uses the repository artifact API shape directly. It should paginate through repository artifacts instead of assuming the first page contains the desired result.

If an artifact endpoint returns `404`, do not stop immediately. First confirm whether `gh repo view` resolves the repository to a different `nameWithOwner`, then retry the artifact lookup with that canonical repository. If the canonical repository still returns `404`, explain whether the repository exists but exposes no accessible artifact API, or whether the original repo path itself was stale.

When recent successful runs exist but each run's artifact endpoint returns zero artifacts, say that explicitly. That is a different outcome from "artifact lookup failed" and usually means the workflow distributed the build elsewhere or did not upload an Actions artifact.

If a workflow must be triggered, add workflow inputs when required.

If multiple artifacts exist, match by platform or ask the user which artifact to install.

When the repository follows an artifact naming convention tied to commit SHA, prefer an existing artifact for the target commit before triggering a new workflow.

For `destination=device`, only use workflows that are already configured to sign for device installation. Do not require any specific signing toolchain from this skill. Do not use this skill to create certificates, provisioning profiles, or signing configuration from scratch during a normal install request.

## Create The Tophat Recipe

Create a temporary recipe in `tmp/` with the filename convention `tophat-recipe-<artifact-id>.json`. Use `scripts/make_recipe.py` directly only when you need the raw JSON helper. Prefer `scripts/install_artifact.py` for the full caller flow so recipe naming, cleanup, and user-facing status stay consistent. The provider ID must be `gha`, and the recipe must include:

- `owner`
- `repo`
- `artifact_id`

When `owner` and `repo` are omitted, infer them from the current Git checkout.

Do not use another provider from this skill.

## Install

Prefer `scripts/install_artifact.py` for the install flow. It should create `tmp/tophat-recipe-<artifact-id>.json`, call `scripts/install_with_tophat.py`, print the user-facing status, and remove the temporary recipe unless the user explicitly wants to keep it for debugging.

On a normal successful install, print one concise green success line that includes the source, artifact ID, platform, and destination when present. On the known timeout case, do not claim the build is fully installed; report that installation may still be in progress in Tophat instead.

`scripts/install_with_tophat.py` should treat the known `tophatctl` timeout as "install may still be in progress in Tophat" instead of a definitive failure.

If the user asks for a device install but the repository has no known signed-device CI path, stop and explain that a signed device artifact must exist first. Recommend `simulator` as the fallback destination when appropriate.

## Reference Notes

Read `references/public-contract.md` when you need the public Tophat schema, the GitHub Actions provider details, or command examples.
