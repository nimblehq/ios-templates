#!/usr/bin/env python3

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from gha import infer_owner_repo_from_git


def parse_key_value(item: str) -> tuple[str, str]:
    if "=" not in item:
        raise argparse.ArgumentTypeError(f"expected key=value, got: {item}")
    key, value = item.split("=", 1)
    key = key.strip()
    value = value.strip()
    if not key:
        raise argparse.ArgumentTypeError(f"missing key in: {item}")
    return key, value


def build_provider_parameters(
    provider: str,
    owner: str | None,
    repo: str | None,
    artifact_id: str | None,
    extra_parameters: dict[str, str] | None = None,
) -> dict[str, str]:
    provider_parameters = dict(extra_parameters or {})

    if provider != "gha":
        return provider_parameters

    if not owner or not repo:
        inferred = infer_owner_repo_from_git()
        if inferred:
            inferred_owner, inferred_repo = inferred
            owner = owner or inferred_owner
            repo = repo or inferred_repo

    missing = [
        name
        for name, value in (
            ("owner", owner),
            ("repo", repo),
            ("artifact-id", artifact_id),
        )
        if not value
    ]
    if missing:
        missing_list = ", ".join(missing)
        raise ValueError(
            f"provider 'gha' requires --owner, --repo, and --artifact-id; missing: {missing_list}"
        )

    return {
        "owner": owner,
        "repo": repo,
        "artifact_id": artifact_id,
        **provider_parameters,
    }


def build_recipe(
    provider: str,
    platform: str,
    destination: str | None,
    provider_parameters: dict[str, str],
    launch_arguments: list[str] | None = None,
) -> list[dict[str, Any]]:
    return [
        {
            "artifactProviderID": provider,
            "artifactProviderParameters": provider_parameters,
            "launchArguments": list(launch_arguments or []),
            "platformHint": platform,
            "destinationHint": destination,
        }
    ]


def write_recipe(recipe: list[dict[str, Any]], output_path: Path) -> None:
    output = json.dumps(recipe, indent=2) + "\n"
    output_path.write_text(output)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Create a public tophatctl recipe JSON file."
    )
    parser.add_argument("--provider", default="gha", help="Tophat artifact provider ID.")
    parser.add_argument("--owner", help="GitHub owner for the public gha provider.")
    parser.add_argument("--repo", help="GitHub repository for the public gha provider.")
    parser.add_argument(
        "--artifact-id",
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
        "--output",
        help="Write JSON to this path instead of stdout.",
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

    if args.output:
        write_recipe(recipe, Path(args.output))
    else:
        sys.stdout.write(json.dumps(recipe, indent=2) + "\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
