#!/usr/bin/env python3

import argparse
import importlib.util
import json
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path


def load_gha_module():
    gha_path = Path(__file__).with_name("gha")
    loader = SourceFileLoader("gha_helpers", str(gha_path))
    spec = importlib.util.spec_from_loader("gha_helpers", loader)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load helpers from {gha_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


GHA = load_gha_module()


def parse_key_value(item: str) -> tuple[str, str]:
    if "=" not in item:
        raise argparse.ArgumentTypeError(f"expected key=value, got: {item}")
    key, value = item.split("=", 1)
    key = key.strip()
    value = value.strip()
    if not key:
        raise argparse.ArgumentTypeError(f"missing key in: {item}")
    return key, value


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

    provider_parameters = dict(args.param)

    if args.provider == "gha":
        if not args.owner or not args.repo:
            inferred = GHA.infer_owner_repo_from_git()
            if inferred:
                inferred_owner, inferred_repo = inferred
                args.owner = args.owner or inferred_owner
                args.repo = args.repo or inferred_repo

        missing = [
            name
            for name, value in (
                ("owner", args.owner),
                ("repo", args.repo),
                ("artifact-id", args.artifact_id),
            )
            if not value
        ]
        if missing:
            parser.error(
                "provider 'gha' requires --owner, --repo, and --artifact-id; "
                f"missing: {', '.join(missing)}"
            )
        provider_parameters = {
            "owner": args.owner,
            "repo": args.repo,
            "artifact_id": args.artifact_id,
            **provider_parameters,
        }

    recipe = [
        {
            "artifactProviderID": args.provider,
            "artifactProviderParameters": provider_parameters,
            "launchArguments": args.launch_arg,
            "platformHint": args.platform,
            "destinationHint": args.destination,
        }
    ]

    output = json.dumps(recipe, indent=2) + "\n"

    if args.output:
        path = Path(args.output)
        path.write_text(output)
    else:
        sys.stdout.write(output)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
