---
name: commit
description: Generate and create a git commit following Nimble's Compass convention
             ([ID] Verb message). Auto-extracts issue ID from branch name.
             Use when asked to commit the current work or create a git commit.
---

You are creating a git commit following Nimble's Compass commit convention.

## Nimble Commit Convention

**Format:** `[<ID>] Verb message`

Rules:
- **Verb tense:** Present imperative — "Fix", "Add", "Remove", "Update", "Refactor" (never past tense)
- **Capitalization:** Capitalize the first word after the bracket
- **No colon** after the bracket — just a space before the verb
- **Periods** only when the message has multiple sentences
- **Be specific:** Avoid generic messages like "Resolve feedback" or "Fix comments"
- **One concern per commit:** If you'd use "and", consider two commits

Examples of correct messages:
- `[#42] Fix crash on launch when user is not authenticated`
- `[GT-7108] Add order cancellation flow`
- `[593] Refactor repo structure`
- `[PROJ-100] Remove UIKit scaffolding from template`

## Step 1 — Gather context

Run these commands in parallel to understand the current state:
- `git branch --show-current` — get the branch name
- `git status` — see staged and unstaged files
- `git diff --staged` — see what is staged
- `git diff` — see what is unstaged

## Step 2 — Determine the issue ID

Extract the issue ID using this priority order:

1. **Argument passed to the skill** — if the user ran `/commit 593`, use `593`
2. **Branch name** — parse the current branch with these patterns (first match wins):

   | Branch example | Extracted ID |
   |----------------|-------------|
   | `chore/593-refactor-repo` | `593` |
   | `feature/GT-7108-add-login` | `GT-7108` |
   | `fix/#42-crash-on-launch` | `#42` |
   | `feature/PROJ-100-something` | `PROJ-100` |

   Pattern: after the first `/`, match `(#?\d+|[A-Z]+-\d+)` followed by `-` or end-of-string.

3. **Ask the user** only if neither source yields an ID.

If the extracted ID already starts with `#` (e.g. `#42`), use it as-is. If it is a plain number (e.g. `593`), format it as `#593`. If it is a Jira-style key (e.g. `GT-7108`), use it as-is without `#`.

## Step 3 — Stage and commit immediately

If the changes obviously belong to one concern, proceed without asking for approval. If the diff appears to contain multiple unrelated changes (e.g. a feature addition mixed with an unrelated bug fix or refactor), stop and ask the user how to split the commit.

1. Stage files **by name** (never use `git add -A` or `git add .`). Use `git add <file> [<file> ...]` for exactly the files that belong to this commit.
2. Create the commit:

```bash
git commit -m "$(cat <<'EOF'
[<ID>] <Verb> <specific message>
EOF
)"
```

3. Run `git log --oneline -1` and show the user the result.

## Edge cases

- **Skip CI:** Only prepend `[skip ci]` when the user explicitly requests it. Format: `[skip ci] [#ID] Verb message`
- **No staged or unstaged changes:** Inform the user there is nothing to commit.
- **Amend:** Only amend if the user explicitly asks to amend. Warn that amending a published commit rewrites history.
