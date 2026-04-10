#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

from install_with_tophat import (
    STATUS_INSTALLED,
    STATUS_PENDING,
    install_recipe,
)
from make_recipe import build_provider_parameters, build_recipe, parse_key_value, write_recipe


GREEN = "\033[32m"
YELLOW = "\033[33m"
RESET = "\033[0m"


def colorize(message: str, color: str) -> str:
    return f"{color}{message}{RESET}"


def format_success_message(
    source: str,
    artifact_id: str,
    platform: str,
    destination: str | None,
    repo: str | None,
) -> str:
    parts = [
        f"Installed build successfully: {source}",
        f"artifact {artifact_id}",
        platform,
    ]
    if destination:
        parts.append(destination)
    if repo:
        parts.append(repo)
    return " · ".join(parts)


def format_pending_message(
    source: str,
    artifact_id: str,
    platform: str,
    destination: str | None,
    repo: str | None,
) -> str:
    parts = [
        f"Install is still in progress in Tophat: {source}",
        f"artifact {artifact_id}",
        platform,
    ]
    if destination:
        parts.append(destination)
    if repo:
        parts.append(repo)
    return " · ".join(parts)


def recipe_path_for_artifact(tmp_dir: Path, artifact_id: str) -> Path:
    return tmp_dir / f"tophat-recipe-{artifact_id}.json"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Create a Tophat recipe, install it, and print user-facing status."
    )
    parser.add_argument("--provider", default="gha", help="Tophat artifact provider ID.")
    parser.add_argument("--owner", help="GitHub owner for the public gha provider.")
    parser.add_argument("--repo", help="GitHub repository for the public gha provider.")
    parser.add_argument(
        "--artifact-id",
        required=True,
        help="GitHub Actions artifact ID for the public gha provider.",
    )
    parser.add_argument(
        "--platform",
        required=True,
        choices=("ios", "android"),
        help="Recipe platformHint.",
    )
    parser.add_argument(
        "--destination",
        choices=("simulator", "device"),
        help="Recipe destinationHint.",
    )
    parser.add_argument(
        "--source",
        required=True,
        help="Short source label used in the user-facing status message.",
    )
    parser.add_argument(
        "--launch-arg",
        action="append",
        default=[],
        help="Launch argument to pass through to the app. Repeat as needed.",
    )
    parser.add_argument(
        "--param",
        action="append",
        default=[],
        type=parse_key_value,
        help="Additional artifactProviderParameters as key=value. Repeat as needed.",
    )
    parser.add_argument(
        "--tmp-dir",
        default="tmp",
        help="Directory for the temporary recipe file.",
    )
    parser.add_argument(
        "--keep-recipe",
        action="store_true",
        help="Keep the generated recipe file for debugging.",
    )
    args = parser.parse_args()

    try:
        provider_parameters = build_provider_parameters(
            provider=args.provider,
            owner=args.owner,
            repo=args.repo,
            artifact_id=args.artifact_id,
            extra_parameters=dict(args.param),
        )
    except ValueError as exc:
        parser.error(str(exc))

    recipe = build_recipe(
        provider=args.provider,
        platform=args.platform,
        destination=args.destination,
        provider_parameters=provider_parameters,
        launch_arguments=args.launch_arg,
    )

    tmp_dir = Path(args.tmp_dir)
    tmp_dir.mkdir(parents=True, exist_ok=True)
    recipe_path = recipe_path_for_artifact(tmp_dir, args.artifact_id)
    write_recipe(recipe, recipe_path)

    try:
        result = install_recipe(recipe_path)
    finally:
        if not args.keep_recipe and recipe_path.exists():
            recipe_path.unlink()

    if result.stdout:
        print(result.stdout)
    if result.status == STATUS_INSTALLED:
        print(
            colorize(
                format_success_message(
                    source=args.source,
                    artifact_id=args.artifact_id,
                    platform=args.platform,
                    destination=args.destination,
                    repo=args.repo,
                ),
                GREEN,
            )
        )
        return 0

    if result.status == STATUS_PENDING:
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        print(
            colorize(
                format_pending_message(
                    source=args.source,
                    artifact_id=args.artifact_id,
                    platform=args.platform,
                    destination=args.destination,
                    repo=args.repo,
                ),
                YELLOW,
            )
        )
        return 0

    if result.stderr:
        print(result.stderr, file=sys.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
