#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import sys
from typing import Any


def parse_github_owner_repo(remote_url: str) -> tuple[str, str] | None:
    remote_url = remote_url.strip()
    patterns = (
        r"^git@github\.com:(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
        r"^https://github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
        r"^ssh://git@github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$",
    )
    for pattern in patterns:
        match = re.match(pattern, remote_url)
        if match:
            return match.group("owner"), match.group("repo")
    return None


def infer_owner_repo_from_git() -> tuple[str, str] | None:
    preferred_remotes = ("origin", "upstream")
    checked = set()

    for remote in preferred_remotes:
        checked.add(remote)
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
        remote_name = parts[0]
        remote_url = parts[1]
        if remote_name in checked:
            continue
        parsed = parse_github_owner_repo(remote_url)
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


def run_gh_json_with_repo_hint(args: list[str], repo: str) -> Any:
    try:
        return run_gh_json(args)
    except SystemExit as exc:
        message = str(exc)
        if "Not Found (HTTP 404)" not in message:
            raise
        raise SystemExit(
            "GitHub artifact lookup returned 404 for "
            f"{repo}. The repository exists if `gh repo view {repo}` succeeds, "
            "so this usually means the artifact API path is unavailable, not accessible "
            "to your token, or the original repo path was stale before canonicalization."
        ) from exc


def canonicalize_repo(repo: str) -> tuple[str, bool]:
    try:
        payload = run_gh_json(["repo", "view", repo, "--json", "nameWithOwner"])
    except SystemExit as exc:
        raise SystemExit(
            f"GitHub repository lookup failed for {repo}. "
            "Check that the repository exists and your gh auth can access it."
        ) from exc

    canonical_repo = payload.get("nameWithOwner") or repo
    return canonical_repo, canonical_repo != repo


def normalize_sha(value: str) -> str:
    return value.strip().lower()


def sha_matches(head_sha: str, requested_sha: str) -> bool:
    if not requested_sha:
        return True
    normalized_head = normalize_sha(head_sha)
    normalized_requested = normalize_sha(requested_sha)
    return normalized_head.startswith(normalized_requested)


def workflow_run_matches_ref(workflow_run: dict[str, Any], ref: str, sha: str) -> bool:
    head_branch = workflow_run.get("head_branch") or workflow_run.get("headBranch") or ""
    head_sha = workflow_run.get("head_sha") or workflow_run.get("headSha") or ""

    if ref and head_branch != ref:
        return False
    if not sha_matches(head_sha, sha):
        return False
    return True


def list_repo_artifacts(repo: str) -> list[dict[str, Any]]:
    artifacts: list[dict[str, Any]] = []
    page = 1

    while True:
        payload = run_gh_json_with_repo_hint(
            [
                "api",
                f"repos/{repo}/actions/artifacts",
                "-F",
                "per_page=100",
                "-F",
                f"page={page}",
            ],
            repo=repo,
        )
        page_artifacts = payload.get("artifacts", [])
        if not page_artifacts:
            break
        artifacts.extend(page_artifacts)
        if len(page_artifacts) < 100:
            break
        page += 1

    return artifacts


def list_runs(repo: str, ref: str) -> list[dict[str, Any]]:
    args = [
        "run",
        "list",
        "--repo",
        repo,
        "--limit",
        "100",
        "--json",
        "databaseId,headBranch,headSha,name,status,conclusion,createdAt,updatedAt,url",
    ]
    if ref:
        args.extend(["--branch", ref])
    payload = run_gh_json(args)
    if not isinstance(payload, list):
        raise SystemExit("Failed to parse gh run list output.")
    return payload


def list_run_artifacts(repo: str, run_id: int) -> list[dict[str, Any]]:
    payload = run_gh_json_with_repo_hint(
        ["api", f"repos/{repo}/actions/runs/{run_id}/artifacts"],
        repo=repo,
    )
    artifacts = payload.get("artifacts", [])
    for artifact in artifacts:
        workflow_run = artifact.get("workflow_run") or {}
        if not workflow_run:
            artifact["workflow_run"] = {"id": run_id}
    return artifacts


def list_matching_run_artifacts(repo: str, ref: str, sha: str) -> list[dict[str, Any]]:
    runs = list_runs(repo, ref=ref)
    matching_runs = [
        run
        for run in runs
        if workflow_run_matches_ref(run, ref=ref, sha=sha)
    ]

    artifacts: list[dict[str, Any]] = []
    for run in matching_runs:
        run_id = run.get("databaseId")
        if not run_id:
            continue
        run_artifacts = list_run_artifacts(repo, int(run_id))
        for artifact in run_artifacts:
            workflow_run = artifact.get("workflow_run") or {}
            if "head_branch" not in workflow_run and run.get("headBranch"):
                workflow_run["head_branch"] = run.get("headBranch")
            if "head_sha" not in workflow_run and run.get("headSha"):
                workflow_run["head_sha"] = run.get("headSha")
            artifact["workflow_run"] = workflow_run
        artifacts.extend(run_artifacts)

    return artifacts


def resolve_pr_ref(repo: str, pr: int) -> tuple[str, str]:
    payload = run_gh_json(["api", f"repos/{repo}/pulls/{pr}"])
    head = payload.get("head") or {}
    head_ref = head.get("ref") or ""
    head_sha = head.get("sha") or ""
    if not head_ref or not head_sha:
        raise SystemExit(f"Could not resolve PR #{pr} to a head ref and SHA.")
    return head_ref, head_sha


def list_artifacts(
    repo: str,
    ref: str,
    sha: str,
    pr: int | None,
    run_id: int | None,
    platform: str,
) -> int:
    repo, repo_was_canonicalized = canonicalize_repo(repo)
    if repo_was_canonicalized:
        print(f"Using canonical GitHub repository: {repo}", file=sys.stderr)

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
    filtered_artifacts: list[dict[str, Any]] = []

    for artifact in artifacts:
        if artifact.get("expired"):
            continue

        workflow_run = artifact.get("workflow_run") or {}
        workflow_run_id = workflow_run.get("id")
        head_branch = workflow_run.get("head_branch") or ""
        head_sha = workflow_run.get("head_sha") or ""
        name = artifact.get("name") or ""

        if run_id is not None and workflow_run_id != run_id:
            continue

        if not workflow_run_matches_ref(workflow_run, ref=ref, sha=sha):
            continue

        if platform and platform.lower() not in name.lower():
            continue

        filtered_artifacts.append(artifact)

    filtered_artifacts.sort(
        key=lambda artifact: artifact.get("created_at") or "",
        reverse=True,
    )

    for artifact in filtered_artifacts:
        workflow_run = artifact.get("workflow_run") or {}
        name = artifact.get("name") or ""
        head_branch = workflow_run.get("head_branch") or ""
        head_sha = workflow_run.get("head_sha") or ""
        short_sha = head_sha[:7]
        created_at = artifact.get("created_at") or ""
        print(
            "\t".join(
                [
                    str(artifact.get("id", "")),
                    name,
                    head_branch,
                    short_sha,
                    created_at,
                ]
            )
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
    list_parser.add_argument(
        "--pr",
        type=int,
        help="PR number to resolve to its current head branch and SHA.",
    )
    list_parser.add_argument(
        "--run-id",
        type=int,
        help="Workflow run ID to match against artifact.workflow_run.id.",
    )
    list_parser.add_argument(
        "--platform",
        default="",
        choices=("ios", "android", ""),
        help="Platform substring to match in artifact names.",
    )

    args = parser.parse_args()

    if args.command == "list-artifacts":
        repo = args.repo
        if not repo:
            inferred = infer_owner_repo_from_git()
            if not inferred:
                raise SystemExit("Could not infer GitHub repository from git remotes.")
            owner, repository = inferred
            repo = f"{owner}/{repository}"
        return list_artifacts(
            repo=repo,
            ref=args.ref,
            sha=args.sha,
            pr=args.pr,
            run_id=args.run_id,
            platform=args.platform,
        )

    parser.print_help(sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
