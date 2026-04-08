#!/usr/bin/env python3

import argparse
import subprocess
import sys
from pathlib import Path


TOPHATCTL_PATH = "/Applications/Tophat.app/Contents/MacOS/tophatctl"
TIMEOUT_MESSAGE = "Error: The operation timed out."


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Install a Tophat recipe file and treat the known CLI timeout as in-progress."
    )
    parser.add_argument("recipe", help="Path to a Tophat recipe JSON file.")
    args = parser.parse_args()

    recipe_path = Path(args.recipe).resolve()
    if not recipe_path.exists():
        parser.error(f"Recipe file not found: {recipe_path}")

    result = subprocess.run(
        [TOPHATCTL_PATH, "install", str(recipe_path)],
        check=False,
        capture_output=True,
        text=True,
    )

    stdout = result.stdout.strip()
    stderr = result.stderr.strip()
    combined = "\n".join(part for part in (stdout, stderr) if part)

    if result.returncode == 0:
        if combined:
            print(combined)
        return 0

    if TIMEOUT_MESSAGE in combined:
        if stdout:
            print(stdout)
        print(
            "Tophat CLI timed out while waiting for completion. "
            "The install request was sent and installation may still be in progress in the Tophat app.",
            file=sys.stderr,
        )
        return 0

    if combined:
        print(combined, file=sys.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
