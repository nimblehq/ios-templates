---
name: tophat-build-install
description: Find, build, and install mobile artifacts for the current repository through GitHub Actions and Tophat. Use when an agent or model needs to help developers, PMs, or reviewers test in-progress work without stashing local changes, switching branches, building locally, or waiting for a manually shared QA build. Handle requests like "install the latest build from main", "install PR #123 on my simulator", or "build this branch and install it". Infer the current GitHub repository from `git remote -v` or `git remote get-url origin` by default. This skill is GitHub Actions only and requires `gh` CLI for build lookup and workflow dispatch.
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
- Repository: derive owner and repo from the current checkout first. Prefer `git remote get-url origin`, then fall back to `git remote -v`. Ask only if there is no usable GitHub remote.
- Source selector: branch, PR number, workflow run ID, or explicit artifact ID.
- Workflow: workflow file or workflow name when a new build must be triggered.
- Artifact choice: artifact name when a run publishes multiple artifacts.
- Destination: `simulator` or `device` when the user specifies it or when the build output differs by target.
- Launch arguments: only if the app needs them.

If the user says "latest build", prefer the latest successful existing run for the requested branch instead of forcing a rebuild. If the user says "build", "rebuild", or "trigger", dispatch a new workflow run first.

If the user already supplies an explicit `artifact_id`, you may skip build lookup, but still keep the workflow within the GitHub Actions artifact path.

For requests in the current repository, do not ask for owner or repo unless Git remotes are missing or point somewhere non-GitHub.

Prefer defaulting to the current repository over asking broad clarifying questions.

## Validate Prerequisites

Before installing, confirm:

- `gh` is authenticated
- Tophat is installed and running
- Tophat exposes the `gha` provider
- the helper scripts in `scripts/` are available from the skill directory

Use `/Applications/Tophat.app/Contents/MacOS/tophatctl` as the Tophat CLI path. Require Tophat to be installed and running. Require a GitHub personal access token to already be configured in Tophat's GitHub Actions extension settings. Require the GitHub Actions provider ID `gha` to be present in `tophatctl list providers`. Here, `gha` is Tophat's provider ID for the GitHub Actions extension.

If `gh` is not authenticated, the GitHub PAT is not configured in Tophat, or `gha` is not installed, stop and tell the user what is missing. Do not fall back to GitHub MCP, raw REST calls, or another artifact provider.

## Default Behavior

Use this decision order:

1. Infer `owner/repo` from the current checkout.
2. Determine the target ref or artifact from the user request.
3. If the user gave an explicit artifact ID, install it directly.
4. Otherwise, look for an existing matching artifact before triggering a new build.
5. Trigger a workflow only when no suitable artifact already exists or when the user explicitly asks for a rebuild.

This keeps the skill useful for both developer and PM flows, while minimizing unnecessary builds.

## Resolve The Build

Resolve the user's target into a concrete artifact. Use `gh` when you need to inspect PRs, workflows, runs, or artifacts. Use `scripts/gha list-artifacts` when you want the local helper to list non-expired artifacts for the current repo or a chosen ref.

If a workflow must be triggered, add workflow inputs when required.

If multiple artifacts exist, match by platform or ask the user which artifact to install.

When the repository follows an artifact naming convention tied to commit SHA, prefer an existing artifact for the target commit before triggering a new workflow.

## Create The Tophat Recipe

Create a temporary recipe in `tmp/` with `scripts/make_recipe.py`. The provider ID must be `gha`, and the recipe must include:

- `owner`
- `repo`
- `artifact_id`

When `owner` and `repo` are omitted, infer them from the current Git checkout.

Do not use another provider from this skill.

## Install

Install through `scripts/install_with_tophat.py` using the temporary recipe. After `tophatctl` returns a result, remove the temporary recipe unless the user explicitly wants to keep it for debugging.

When the install succeeds, report the branch or PR, workflow run, artifact ID, platform, and destination that were used.

`scripts/install_with_tophat.py` should treat the known `tophatctl` timeout as "install may still be in progress in Tophat" instead of a definitive failure.

## Reference Notes

Read `references/public-contract.md` when you need the public Tophat schema, the GitHub Actions provider details, or command examples.
