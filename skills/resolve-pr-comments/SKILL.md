---
name: resolve-pr-comments
description: Guided workflow to address, reply to, and resolve GitHub PR review threads — one at a time, collaboratively. Use when the user says `/resolve-pr-comments` optionally followed by a PR URL or a comment URL.
disable-model-invocation: true
triggers:
  - /resolve-pr-comments
  - resolve PR comments
  - address PR review
  - respond to code review
  - reply to PR thread
---

# resolve-pr-comments

Guided workflow to address, reply to, and resolve GitHub PR review threads — one at a time, collaboratively.

---

## Fetch Threads Workflow

Retrieve unresolved review threads from GitHub.

### Workflow: Fetch Unresolved Threads

1. Parse the URL provided by the user:
   - **PR URL** (`/pull/123`) — process all unresolved threads
   - **Comment URL** (`/pull/123#discussion_r<ID>`) — process that single thread
   - If no URL is provided, ask the user before proceeding
2. Extract `owner`, `repo`, and `pull_number` from the URL
3. Use `gh` CLI to fetch review threads for the PR
4. Filter to threads where `isResolved == false`
5. If a comment URL was given, further filter to the thread containing the comment with `databaseId == <ID>`
6. If no unresolved threads exist, report that immediately and stop
7. **Validation:** Threads fetched; unresolved threads identified; pagination limits noted (>100 threads or >20 comments per thread may be truncated — use comment URL to process in batches)

---

## Per-Thread Resolution Workflow

Work through each unresolved thread collaboratively.

### Workflow: Resolve a Thread

For each unresolved thread, display context then work through steps 1–6:

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Thread: <path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Comments:
  [author] createdAt
  > body
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Step 1 — Analyze and propose

Reads the file at `path` to get current context, then proposes one of:

- **"No code change needed."** — explain what reply to send and why no change is required
- **"Code change needed."** — describe the change; ask: *"Should I make this change?"*

Wait for user confirmation or adjustment before proceeding.

#### Step 2 — Implement (if code change)

Make the code change. **Do not commit or push yet.**

#### Step 3 — Draft commit message and reply, then confirm

Compose both drafts and present them together for user approval.

**Commit message:** Use the `/commit` skill convention (`[#ID] Verb message`). Derive the issue ID from the branch name (e.g. `chore/609-add-skill` → `#609`).

**Reply:** Vary the phrasing naturally based on the nature of the comment:
  - `"Good catch, fixed in <sha>."`
  - `"Good point, updated in <sha>."`
  - `"Agreed, refactored in <sha>."`
  - `"Done, updated in <sha>."`
  - `"Fixed in <sha>."`
  - Avoid repeating the same opener across multiple threads in the same PR.
  - Use `<sha>` as a placeholder since the commit hasn't happened yet.

**No-code-change reply:** Brief factual explanation, 1–2 sentences. If referencing a specific piece of code, first use search or read to locate the snippet and determine the correct line number(s), then include it as a code block:
  ````
  ```{language inferred from file extension}
  // {path}, line {N} — https://github.com/OWNER/REPO/blob/BRANCH/path/to/file#LN
  relevant code here...
  ```
  ````
  Use the current branch name for the link. Keep the snippet short.

No emoji unless the user uses them first.

Show both drafts at once:

> **Commit message:** `"[#609] Fix wording in skill documentation"`
> **Reply:** `"Good point, updated in <sha>."`
> Does this look good?

Wait for explicit approval (or edits) before proceeding.

#### Step 4 — Commit and push

Once the user approves:

1. Stage and commit using the `/commit` skill with the approved message
2. Capture the short SHA: `git log --oneline -1`
3. Push: `git push`

#### Step 5 — Post the reply

Replace `<sha>` in the reply with the real short SHA, then post using `in_reply_to` (more reliable than the `/replies` endpoint, which 404s when the target comment is itself a reply):

```bash
gh api repos/OWNER/REPO/pulls/PULL_NUMBER/comments \
  -X POST \
  -f body="REPLY TEXT" \
  -F in_reply_to=COMMENT_DATABASE_ID
```

`COMMENT_DATABASE_ID` is the `databaseId` of the **thread's top-level comment** (the oldest comment in the thread). `PULL_NUMBER` is the PR number extracted from the URL.

#### Step 6 — Mark thread resolved (conditional)

Only resolve if the reply is conclusive — a code fix was made, or the explanation fully closes the discussion with no open questions.

**Do not resolve** if:
- The reply asks a follow-up question or invites further discussion
- The reply is a partial response pending reviewer confirmation
- The user's reply draft suggests the thread should stay open

Ask the user: **"Should I mark this thread as resolved?"** if it's ambiguous.

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
      thread { isResolved }
    }
  }'
```

**Validation:** Code change implemented (if required); commit pushed; reply posted with real SHA; thread resolved if conclusive

---

## Reply Conventions

| Situation | Reply format |
|-----------|-------------|
| Code changed | Vary naturally: `"Good catch, fixed in <sha>."` / `"Good point, updated in <sha>."` / `"Agreed, refactored in <sha>."` — match the tone, avoid repeating openers |
| No code change | Brief factual explanation, 1–2 sentences |
| Declined / won't fix | Polite explanation of why, 1–2 sentences |

- Never post a reply without user approval
- No emoji unless the user uses them first
- Keep replies short and professional

---

## Error Handling

| Error | Action |
|-------|--------|
| Thread already resolved | Skip silently and continue |
| `gh api` error posting reply | Show the error and ask the user how to proceed — do not auto-retry |
| No unresolved threads | Report immediately and stop |
| >100 threads or >20 comments per thread | Results may be truncated — use a comment URL to process in batches |

---

## Output Artifacts

| When you ask for... | You get... |
|---------------------|------------|
| PR URL | All unresolved threads processed one at a time |
| Comment URL | That single thread addressed |
| Completion | `Done — X thread(s) resolved.` summary |
