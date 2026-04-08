#!/usr/bin/env python3
"""
PR Report - Categorize open PRs by action required and post to Slack.

Posts a new message at the start of each day and updates it on subsequent runs.
The daily Slack message timestamp is stored in PR_REPORT_TS_FILE (managed via Actions cache).

Environment variables:
    GITHUB_USER           Login of the user to evaluate PRs from (e.g. github.actor)
    GITHUB_REPOSITORY     owner/repo (e.g. nimblehq/ios-templates)
    SLACK_BOT_TOKEN       Slack bot token (xoxb-...) — needs chat:write, users:read, users:read.email
    SLACK_CHANNEL_ID      Slack channel ID (e.g. C1234567890)
    PR_REPORT_TS_FILE     Path to file storing DATE:TS (default: .pr_report_ts)
"""

import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path


class Category(Enum):
    FIX_CONFLICT = "fixConflict"
    NEEDS_REBASE = "needsRebase"
    NEEDS_REVIEW = "needsReview"
    READY_TO_MERGE = "readyToMerge"


SLACK_EMOJI = {
    Category.FIX_CONFLICT:  ":red_circle:",
    Category.NEEDS_REBASE:  ":arrows_counterclockwise:",
    Category.NEEDS_REVIEW:  ":mag:",
    Category.READY_TO_MERGE: ":rocket:",
}

SLACK_LABEL = {
    Category.FIX_CONFLICT:  "Fix Conflict",
    Category.NEEDS_REBASE:  "Needs Rebase",
    Category.NEEDS_REVIEW:  "Needs Review",
    Category.READY_TO_MERGE: "Ready to Merge",
}

PRIORITY = [
    Category.FIX_CONFLICT,
    Category.NEEDS_REBASE,
    Category.NEEDS_REVIEW,
    Category.READY_TO_MERGE,
]


# ── GitHub helpers ────────────────────────────────────────────────────────────

def gh(*args):
    result = subprocess.run(["gh"] + list(args), capture_output=True, text=True)
    if result.returncode != 0:
        print(f"gh error: {result.stderr.strip()}", file=sys.stderr)
        return None
    return result.stdout.strip()


def list_prs(repo):
    fields = ",".join([
        "number", "title", "url", "author",
        "reviewDecision", "mergeable", "statusCheckRollup", "isDraft",
    ])
    output = gh("pr", "list", "--repo", repo, "--state", "open", "--limit", "100", "--json", fields)
    return json.loads(output) if output else []


def get_mergeable_state(repo, pr_number):
    out = gh("api", f"repos/{repo}/pulls/{pr_number}", "-q", ".mergeable_state")
    return out or "unknown"


def github_email(login):
    out = gh("api", f"users/{login}", "-q", ".email")
    return out if out and out != "null" else None


def save_daily_ts(ts_file, today, ts):
    Path(ts_file).write_text(f"{today}:{ts}")


# ── PR categorization ─────────────────────────────────────────────────────────

def ci_passing(pr):
    for check in pr.get("statusCheckRollup") or []:
        conclusion = check.get("conclusion") or ""
        status = check.get("status") or ""
        if conclusion in ("FAILURE", "ERROR", "TIMED_OUT", "CANCELLED"):
            return False
        if not conclusion and status in ("IN_PROGRESS", "QUEUED", "PENDING"):
            return False
    return True


def categorize(pr, repo):
    mergeable = pr.get("mergeable", "")
    review_decision = pr.get("reviewDecision") or ""

    if mergeable == "CONFLICTING":
        return Category.FIX_CONFLICT

    if mergeable in ("UNKNOWN", "MERGEABLE"):
        if get_mergeable_state(repo, pr["number"]) == "behind":
            return Category.NEEDS_REBASE

    if review_decision == "APPROVED" and ci_passing(pr) and mergeable == "MERGEABLE":
        return Category.READY_TO_MERGE

    return Category.NEEDS_REVIEW


# ── Slack helpers ─────────────────────────────────────────────────────────────

_slack_user_cache = {}


def slack_mention(token, github_login):
    """Return <@SLACK_ID> for a GitHub user, falling back to @login."""
    if github_login in _slack_user_cache:
        uid = _slack_user_cache[github_login]
    else:
        uid = None
        email = github_email(github_login)
        if email:
            url = f"https://slack.com/api/users.lookupByEmail?email={urllib.parse.quote(email)}"
            req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
            try:
                with urllib.request.urlopen(req) as resp:
                    data = json.loads(resp.read())
                    if data.get("ok"):
                        uid = data["user"]["id"]
            except Exception:
                pass
        _slack_user_cache[github_login] = uid

    return f"<@{uid}>" if uid else f"@{github_login}"


TAG_AUTHOR = {Category.FIX_CONFLICT, Category.NEEDS_REBASE}


def render_slack(grouped, token):
    parts = []
    for cat in PRIORITY:
        prs = grouped.get(cat, [])
        if prs:
            parts.append(f"{SLACK_EMOJI[cat]} *{SLACK_LABEL[cat]}*")
            for pr in prs:
                line = f"- <{pr['url']}|{pr['title']}>"
                if cat in TAG_AUTHOR:
                    author = (pr.get("author") or {}).get("login", "")
                    if author:
                        line += f" {slack_mention(token, author)}"
                parts.append(line)
            parts.append("")
    return "\n".join(parts).strip()


def slack_api(token, method, payload):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"https://slack.com/api/{method}",
        data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}",
        }
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def post_message(token, channel_id, text):
    result = slack_api(token, "chat.postMessage", {
        "channel": channel_id,
        "text": text,
        "mrkdwn": True,
    })
    if not result.get("ok"):
        raise RuntimeError(f"chat.postMessage failed: {result.get('error')}")
    return result["ts"]


def update_message(token, channel_id, ts, text):
    result = slack_api(token, "chat.update", {
        "channel": channel_id,
        "ts": ts,
        "text": text,
        "mrkdwn": True,
    })
    if not result.get("ok"):
        raise RuntimeError(f"chat.update failed: {result.get('error')}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    me = os.environ.get("GITHUB_USER", "").strip()
    repo = os.environ.get("GITHUB_REPOSITORY", "").strip()
    token = os.environ.get("SLACK_BOT_TOKEN", "").strip()
    channel_id = os.environ.get("SLACK_CHANNEL_ID", "").strip()
    ts_file = os.environ.get("PR_REPORT_TS_FILE", ".pr_report_ts").strip()

    for name, val in [("GITHUB_USER", me), ("GITHUB_REPOSITORY", repo),
                      ("SLACK_BOT_TOKEN", token), ("SLACK_CHANNEL_ID", channel_id)]:
        if not val:
            print(f"Error: {name} is not set.", file=sys.stderr)
            sys.exit(1)

    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    existing_ts = None
    ts_path = Path(ts_file)
    if ts_path.exists():
        content = ts_path.read_text().strip()
        if ":" in content:
            stored_date, stored_ts = content.split(":", 1)
            if stored_date == today:
                existing_ts = stored_ts

    print(f"Fetching PRs in {repo}...")
    prs = list_prs(repo)

    if not prs:
        print("No open PRs found.")
        return

    print(f"Categorizing {len(prs)} PR(s)...")
    grouped = {cat: [] for cat in Category}
    for pr in prs:
        if pr.get("isDraft"):
            continue
        grouped[categorize(pr, repo)].append(pr)

    if not any(grouped.values()):
        print("No actionable PRs found.")
        return

    for cat in PRIORITY:
        if grouped[cat]:
            print(f"\n  {SLACK_LABEL[cat]}: {len(grouped[cat])}")
            for pr in grouped[cat]:
                print(f"    #{pr['number']} {pr['title']}")

    message = render_slack(grouped, token)

    try:
        if existing_ts:
            print(f"\nUpdating today's Slack message (ts={existing_ts})...")
            update_message(token, channel_id, existing_ts, message)
            print("✅ Message updated.")
        else:
            print("\nPosting new Slack message...")
            new_ts = post_message(token, channel_id, message)
            save_daily_ts(ts_file, today, new_ts)
            print(f"✅ Message posted (ts={new_ts}).")
    except RuntimeError as e:
        print(f"❌ {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
