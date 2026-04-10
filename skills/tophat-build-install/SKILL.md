---
name: tophat-build-install
description: Find, build, and install mobile artifacts for the current repository through GitHub Actions and Tophat. Use it for requests like "install the latest build from main", "install PR #123 on my simulator", or "build this branch and install it". Default to the current GitHub repository, use `gh` for lookup and workflow dispatch, and use the local helper scripts for artifact listing and Tophat install.
---

# Tophat Build Install

Use this skill to turn a user request into a concrete GitHub Actions artifact install through Tophat.

This skill is GitHub Actions only. Require:

- `gh`
- Tophat at `/Applications/Tophat.app/Contents/MacOS/tophatctl` with the `gha` provider installed
- a repository that already publishes GitHub Actions artifacts

Do not switch to another artifact provider from this skill.

## Inputs

Collect only the missing inputs.

- Platform: `ios` or `android`.
- Repository: derive it from the current checkout first. Ask only if there is no usable GitHub remote.
- Source selector: branch, PR number, workflow run ID, or explicit artifact ID.
- Workflow: only when a new build must be triggered.
- Destination: `simulator` or `device` when it matters.
- Launch arguments: only if the app needs them.

If the user says "latest build", prefer the latest successful existing run for the requested branch instead of forcing a rebuild. If the user says "build", "rebuild", or "trigger", dispatch a new workflow run first.

## Default Flow

Use this order:

1. Infer the current repository.
2. Resolve the target from the user request.
3. If the user gave an explicit artifact ID, install it directly.
4. Otherwise, look for an existing artifact first.
5. Trigger a workflow only when no suitable artifact exists or the user explicitly asked for a rebuild.

## Build Resolution

Resolve the user's target into a concrete artifact. Use `gh` when you need to inspect PRs, workflows, runs, or artifacts. Use `scripts/gha.py list-artifacts` when you want the local helper to list non-expired artifacts for the current repo or a chosen selector.

The helper prefers the repository-wide artifacts endpoint, but if GitHub returns `404` there it should fall back to recent workflow runs instead of stopping immediately.

Prefer this order:

1. If the user gave an explicit artifact ID, install it directly.
2. If the user gave a workflow run ID, list artifacts and match `artifact.workflow_run.id`.
3. If the user gave a PR number, resolve the PR head branch and head SHA, then list artifacts for that head.
4. If the user gave a branch or commit SHA, list artifacts and match branch and-or SHA.
5. Trigger a workflow only when no matching non-expired artifact exists or the user explicitly asked for a rebuild.

`scripts/gha.py list-artifacts` supports these selectors:

- `--ref <branch>`
- `--sha <commit-or-prefix>`
- `--pr <number>`
- `--run-id <database-id>`
- `--platform ios|android`

If multiple artifacts exist, match by platform or ask the user which artifact to install.

## Install

Prefer `scripts/install_artifact.py` for the normal install flow. It creates a temporary recipe, calls Tophat, prints a short status line, and removes the recipe unless `--keep-recipe` is set.

Use `/Applications/Tophat.app/Contents/MacOS/tophatctl` as the Tophat CLI path. Keep that path explicit when reporting missing local tooling so agents do not guess.

Use `scripts/make_recipe.py` directly only when you need the raw recipe JSON.

For `gha`, the recipe must include:

- `owner`
- `repo`
- `artifact_id`

If `owner` and `repo` are omitted, infer them from Git.

Treat the known `tophatctl` timeout as "install may still be in progress in Tophat", not as a hard failure.

For `destination=device`, use only workflows that already produce signed device builds. If that path does not exist, stop and explain it.

## Reference Notes

Read `references/public-contract.md` when you need the public Tophat schema, the GitHub Actions provider details, or command examples.
