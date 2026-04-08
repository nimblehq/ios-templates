#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import sys


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


def run_gh_json(args: list[str]) -> dict:
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


def list_artifacts(repo: str, ref: str, platform: str) -> int:
    payload = run_gh_json(["api", f"repos/{repo}/actions/artifacts"])
    artifacts = payload.get("artifacts", [])

    for artifact in artifacts:
        if artifact.get("expired"):
            continue

        workflow_run = artifact.get("workflow_run") or {}
        head_branch = workflow_run.get("head_branch") or ""
        head_sha = workflow_run.get("head_sha") or ""
        name = artifact.get("name") or ""

        if ref and head_branch != ref:
            continue

        if platform and platform.lower() not in name.lower():
            continue

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
        return list_artifacts(repo=repo, ref=args.ref, platform=args.platform)

    parser.print_help(sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
