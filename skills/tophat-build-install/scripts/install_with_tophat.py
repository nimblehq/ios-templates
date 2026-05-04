#!/usr/bin/env python3

import argparse
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


TOPHATCTL_PATH = "/Applications/Tophat.app/Contents/MacOS/tophatctl"
TIMEOUT_MESSAGE = "Error: The operation timed out."
STATUS_INSTALLED = "installed"
STATUS_PENDING = "pending"
STATUS_FAILED = "failed"


@dataclass
class InstallResult:
    status: str
    returncode: int
    stdout: str
    stderr: str

    @property
    def combined_output(self) -> str:
        return "\n".join(part for part in (self.stdout, self.stderr) if part)


def install_recipe(recipe_path: Path) -> InstallResult:
    if not Path(TOPHATCTL_PATH).exists():
        return InstallResult(
            status=STATUS_FAILED,
            returncode=1,
            stdout="",
            stderr=f"Tophat CLI not found at {TOPHATCTL_PATH}",
        )

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
        return InstallResult(
            status=STATUS_INSTALLED,
            returncode=0,
            stdout=stdout,
            stderr=stderr,
        )

    if TIMEOUT_MESSAGE in combined:
        pending_stderr = (
            "Tophat CLI timed out while waiting for completion. "
            "The install request was sent and installation may still be in progress in the Tophat app."
        )
        return InstallResult(
            status=STATUS_PENDING,
            returncode=0,
            stdout=stdout,
            stderr=pending_stderr,
        )

    return InstallResult(
        status=STATUS_FAILED,
        returncode=result.returncode,
        stdout=stdout,
        stderr=stderr,
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Install a Tophat recipe file with "
            f"{TOPHATCTL_PATH} and treat the known CLI timeout as in-progress."
        )
    )
    parser.add_argument("recipe", help="Path to a Tophat recipe JSON file.")
    args = parser.parse_args()

    recipe_path = Path(args.recipe).resolve()
    if not recipe_path.exists():
        parser.error(f"Recipe file not found: {recipe_path}")

    result = install_recipe(recipe_path)

    if result.status == STATUS_INSTALLED:
        if result.combined_output:
            print(result.combined_output)
        return 0

    if result.status == STATUS_PENDING:
        if result.stdout:
            print(result.stdout)
        print(result.stderr, file=sys.stderr)
        return 0

    if result.combined_output:
        print(result.combined_output, file=sys.stderr)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
