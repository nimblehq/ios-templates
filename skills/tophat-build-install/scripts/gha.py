#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import sys
from typing import Any


GITHUB_REMOTE_PATTERNS = (
    r"^git@github\.com:(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
    r"^https://github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
    r"^ssh://git@github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
)


def parse_github_owner_repo(remote_url: str) -> tuple[str, str] | None:
    remote_url = remote_url.strip()
    for pattern in GITHUB_REMOTE_PATTERNS:
        match = re.match(pattern, remote_url)
        if match:
            return match.group("owner"), match.group("repo")
    return None


def infer_owner_repo_from_git() -> tuple[str, str] | None:
    for remote in ("origin", "upstream"):
        result = subprocess.run(
            ["git", "remote", "get-url", remote],
            check=False,
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            parsed = parse_github_owner_repo(result.stdout)
            if parsed:
                return parsed

    result = subprocess.run(
        ["git", "remote", "-v"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None

    for line in result.stdout.splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue
        parsed = parse_github_owner_repo(parts[1])
        if parsed:
            return parsed

    return None


def run_gh_json(args: list[str]) -> Any:
    result = subprocess.run(
        ["gh", *args],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip() or "gh command failed"
        raise SystemExit(message)
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Failed to parse gh JSON output: {exc}") from exc


def is_not_found_error(message: str) -> bool:
    return "Not Found (HTTP 404)" in message


def canonicalize_repo(repo: str) -> str:
    payload = run_gh_json(["repo", "view", repo, "--json", "nameWithOwner"])
    canonical_repo = payload.get("nameWithOwner") or repo
    if canonical_repo != repo:
        print(f"Using canonical GitHub repository: {canonical_repo}", file=sys.stderr)
    return canonical_repo


def normalize_sha(value: str) -> str:
    return value.strip().lower()


def sha_matches(actual_sha: str, requested_sha: str) -> bool:
    if not requested_sha:
        return True
    return normalize_sha(actual_sha).startswith(normalize_sha(requested_sha))


def workflow_run_matches_ref(workflow_run: dict[str, Any], ref: str, sha: str) -> bool:
    head_branch = workflow_run.get("head_branch") or workflow_run.get("headBranch") or ""
    head_sha = workflow_run.get("head_sha") or workflow_run.get("headSha") or ""
    if ref and head_branch != ref:
        return False
    return sha_matches(head_sha, sha)


def list_repo_artifacts(repo: str) -> list[dict[str, Any]]:
    artifacts: list[dict[str, Any]] = []
    page = 1

    while True:
        try:
            payload = run_gh_json(
                [
                    "api",
                    f"repos/{repo}/actions/artifacts",
                    "-F",
                    "per_page=100",
                    "-F",
                    f"page={page}",
                ]
            )
        except SystemExit as exc:
            if page == 1 and is_not_found_error(str(exc)):
                print(
                    "GitHub repository artifact API returned 404. "
                    "Falling back to recent workflow runs.",
                    file=sys.stderr,
                )
                return list_all_run_artifacts(repo)
            raise
        page_artifacts = payload.get("artifacts", [])
        if not page_artifacts:
            return artifacts
        artifacts.extend(page_artifacts)
        if len(page_artifacts) < 100:
            return artifacts
        page += 1


def list_runs(repo: str, ref: str) -> list[dict[str, Any]]:
    args = [
        "run",
        "list",
        "--repo",
        repo,
        "--limit",
        "100",
        "--json",
        "databaseId,headBranch,headSha",
    ]
    if ref:
        args.extend(["--branch", ref])
    payload = run_gh_json(args)
    if not isinstance(payload, list):
        raise SystemExit("Failed to parse gh run list output.")
    return payload


def list_run_artifacts(repo: str, run_id: int) -> list[dict[str, Any]]:
    payload = run_gh_json(["api", f"repos/{repo}/actions/runs/{run_id}/artifacts"])
    artifacts = payload.get("artifacts", [])
    for artifact in artifacts:
        workflow_run = artifact.get("workflow_run") or {}
        if not workflow_run:
            artifact["workflow_run"] = {"id": run_id}
    return artifacts


def list_matching_run_artifacts(repo: str, ref: str, sha: str) -> list[dict[str, Any]]:
    artifacts: list[dict[str, Any]] = []

    for run in list_runs(repo, ref=ref):
        if not workflow_run_matches_ref(run, ref=ref, sha=sha):
            continue

        run_id = run.get("databaseId")
        if not run_id:
            continue

        for artifact in list_run_artifacts(repo, int(run_id)):
            workflow_run = artifact.get("workflow_run") or {}
            if "head_branch" not in workflow_run and run.get("headBranch"):
                workflow_run["head_branch"] = run.get("headBranch")
            if "head_sha" not in workflow_run and run.get("headSha"):
                workflow_run["head_sha"] = run.get("headSha")
            artifact["workflow_run"] = workflow_run
            artifacts.append(artifact)

    return artifacts


def list_all_run_artifacts(repo: str) -> list[dict[str, Any]]:
    artifacts: list[dict[str, Any]] = []

    for run in list_runs(repo, ref=""):
        run_id = run.get("databaseId")
        if not run_id:
            continue

        for artifact in list_run_artifacts(repo, int(run_id)):
            workflow_run = artifact.get("workflow_run") or {}
            if "head_branch" not in workflow_run and run.get("headBranch"):
                workflow_run["head_branch"] = run.get("headBranch")
            if "head_sha" not in workflow_run and run.get("headSha"):
                workflow_run["head_sha"] = run.get("headSha")
            artifact["workflow_run"] = workflow_run
            artifacts.append(artifact)

    return artifacts


def resolve_pr_ref(repo: str, pr: int) -> tuple[str, str]:
    payload = run_gh_json(["api", f"repos/{repo}/pulls/{pr}"])
    head = payload.get("head") or {}
    head_ref = head.get("ref") or ""
    head_sha = head.get("sha") or ""
    if not head_ref or not head_sha:
        raise SystemExit(f"Could not resolve PR #{pr} to a head ref and SHA.")
    return head_ref, head_sha


def artifact_matches(
    artifact: dict[str, Any],
    ref: str,
    sha: str,
    run_id: int | None,
    platform: str,
) -> bool:
    if artifact.get("expired"):
        return False

    workflow_run = artifact.get("workflow_run") or {}
    if run_id is not None and workflow_run.get("id") != run_id:
        return False
    if not workflow_run_matches_ref(workflow_run, ref=ref, sha=sha):
        return False
    if platform and platform.lower() not in (artifact.get("name") or "").lower():
        return False
    return True


def print_artifacts(artifacts: list[dict[str, Any]]) -> None:
    for artifact in sorted(
        artifacts,
        key=lambda item: item.get("created_at") or "",
        reverse=True,
    ):
        workflow_run = artifact.get("workflow_run") or {}
        print(
            "\t".join(
                [
                    str(artifact.get("id", "")),
                    artifact.get("name") or "",
                    workflow_run.get("head_branch") or "",
                    (workflow_run.get("head_sha") or "")[:7],
                    artifact.get("created_at") or "",
                ]
            )
        )


def list_artifacts(
    repo: str,
    ref: str,
    sha: str,
    pr: int | None,
    run_id: int | None,
    platform: str,
) -> int:
    repo = canonicalize_repo(repo)

    if pr is not None:
        pr_ref, pr_sha = resolve_pr_ref(repo, pr)
        ref = ref or pr_ref
        sha = sha or pr_sha

    if run_id is not None:
        artifacts = list_run_artifacts(repo, run_id)
    elif ref or sha:
        artifacts = list_matching_run_artifacts(repo, ref=ref, sha=sha)
    else:
        artifacts = list_repo_artifacts(repo)

    print_artifacts(
        [
            artifact
            for artifact in artifacts
            if artifact_matches(
                artifact,
                ref=ref,
                sha=sha,
                run_id=run_id,
                platform=platform,
            )
        ]
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="GitHub Actions helpers for the tophat-build-install skill."
    )
    subparsers = parser.add_subparsers(dest="command")

    list_parser = subparsers.add_parser(
        "list-artifacts",
        help="List non-expired GitHub Actions artifacts for the current repo.",
    )
    list_parser.add_argument("--repo", help="Repository in owner/repo format.")
    list_parser.add_argument("--ref", default="", help="Branch name to match.")
    list_parser.add_argument(
        "--sha",
        default="",
        help="Commit SHA or prefix to match against the artifact workflow run.",
    )
    list_parser.add_argument("--pr", type=int, help="PR number to resolve.")
    list_parser.add_argument("--run-id", type=int, help="Workflow run database ID.")
    list_parser.add_argument(
        "--platform",
        default="",
        choices=("ios", "android", ""),
        help="Platform substring to match in artifact names.",
    )

    args = parser.parse_args()

    if args.command != "list-artifacts":
        parser.print_help(sys.stderr)
        return 1

    repo = args.repo
    if not repo:
        inferred = infer_owner_repo_from_git()
        if not inferred:
            raise SystemExit("Could not infer GitHub repository from git remotes.")
        repo = "/".join(inferred)

    return list_artifacts(
        repo=repo,
        ref=args.ref,
        sha=args.sha,
        pr=args.pr,
        run_id=args.run_id,
        platform=args.platform,
    )


if __name__ == "__main__":
    raise SystemExit(main())
