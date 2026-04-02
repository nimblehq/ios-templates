# resolve-pr-comments

Guided workflow to address, reply to, and resolve GitHub PR review threads — one at a time, collaboratively.

## Trigger

Use when the user says `/resolve-pr-comments` optionally followed by a PR URL or a comment URL.

---

## Input

The user provides either:
- **PR URL**: `https://github.com/owner/repo/pull/123` — process all unresolved threads
- **Comment URL**: `https://github.com/owner/repo/pull/123#discussion_r<id>` — process that single thread

If no URL is provided, ask the user for one before proceeding.

Extract `owner`, `repo`, and `pull_number` from the URL.

---

## Step 1 — Fetch threads

### Single comment URL (fragment `#discussion_r<ID>`)

Extract the numeric comment ID from the fragment. Use GraphQL to find the review thread that contains it:

```bash
gh api graphql -f query='
  query {
    repository(owner: "OWNER", name: "REPO") {
      pullRequest(number: PR_NUM) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            diffHunk
            comments(first: 20) {
              nodes {
                databaseId
                author { login }
                body
                createdAt
              }
            }
          }
        }
      }
    }
  }'
```

Filter to the thread whose `comments.nodes` contains a node with `databaseId == <ID>`.

### PR URL (all threads)

Use the same GraphQL query above. Filter to nodes where `isResolved == false`.

---

## Step 2 — Display thread context

For each thread, display clearly:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Thread: <path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Diff hunk:
<diffHunk>

Comments:
  [author] createdAt
  > body

  [author] createdAt
  > body
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 3 — Per-thread loop

For each unresolved thread, work through these steps in order:

### 3a — Analyze and propose

Claude reads the file at `path` to get current context, then proposes one of:

- **"No code change needed."** — explain what reply to send and why no change is required
- **"Code change needed."** — describe the change; ask: *"Should I make this change?"*

Wait for user confirmation or adjustment before proceeding.

### 3b — Implement (if code change)

Make the code change. **Do not commit or push yet.**

### 3c — Draft commit message and reply, then confirm

Compose both drafts and present them together for user approval:

**Commit message:** follow the Nimble Compass convention (`[#ID] Verb message`). Derive the ID from the branch name using the same rules as the `/commit` skill.

**Reply:** vary the phrasing naturally based on the nature of the comment — examples:
  - `"Good catch, fixed in <sha>."`
  - `"Good point, updated in <sha>."`
  - `"Agreed, refactored in <sha>."`
  - `"Done, updated in <sha>."`
  - `"Fixed in <sha>."`
  - `"Updated in <sha>."`
  - Use your judgment — pick whichever fits the tone of the original comment. Avoid repeating the same opener across multiple threads in the same PR.
  - Use a placeholder like `<sha>` since the commit hasn't happened yet.

For a **no-code-change** reply: brief factual explanation, 1–2 sentences max. If referencing a specific piece of code, include it as a code block with a comment on the first line showing the file path, line number, and a link to that file on GitHub:
  ````
  ```{language inferred from file extension}
  // {path}, line {N} — https://github.com/OWNER/REPO/blob/BRANCH/path/to/file#LN
  relevant code here...
  ```
  ````
  Use the current branch name for the link. Include only the most relevant lines — keep the snippet short.

No emoji unless the user adds them.

Show both drafts to the user at once:

> **Commit message:** `"[#595] Fix commit description format"`
> **Reply:** `"Good point, updated in <sha>."`
> Does this look good?

Wait for explicit approval (or edits) before proceeding.

### 3d — Commit, push, then post the reply

Once the user approves:

1. Commit using the approved message:

```bash
git add <files> && git commit -m "APPROVED COMMIT MESSAGE"
```

2. Capture the short SHA:

```bash
git log --oneline -1
```

3. Push:

```bash
git push
```

4. Replace `<sha>` in the reply with the real short SHA, then post it:

### 3e — Post the reply

Use `in_reply_to` on the PR comments endpoint — more reliable than the `/replies` endpoint, which 404s when the target comment is itself a reply:

```bash
gh api repos/OWNER/REPO/pulls/PULL_NUMBER/comments \
  -X POST \
  -f body="REPLY TEXT" \
  -F in_reply_to=COMMENT_DATABASE_ID
```

`COMMENT_DATABASE_ID` is the `databaseId` of the **first comment** in the thread (the root). `PULL_NUMBER` is the PR number extracted from the URL.

### 3e — Mark thread resolved (conditional)

Only resolve the thread if the reply is conclusive — i.e. a code fix was made, or the explanation fully closes the discussion with no open questions.

**Do not resolve** if:
- The reply asks a follow-up question or invites further discussion
- The reply is a partial response pending reviewer confirmation
- The user's reply draft suggests the thread should stay open

Ask the user: **"Should I mark this thread as resolved?"** if it's ambiguous.

When resolving:

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
      thread { isResolved }
    }
  }'
```

---

## Step 4 — Completion

After all threads are processed, report:

```
Done — X thread(s) resolved.
```

---

## Reply conventions (Nimble Compass)

| Situation | Reply format |
|-----------|-------------|
| Code changed | Vary naturally: `"Good catch, fixed in <sha>."` / `"Good point, updated in <sha>."` / `"Agreed, refactored in <sha>."` / `"Fixed in <sha>."` etc. — match the tone, don't repeat the same opener across threads |
| No code change, explanation needed | Brief factual explanation, 1–2 sentences |
| Declined / won't fix | Polite explanation of why, 1–2 sentences |

- Never post a reply without user approval
- No emoji unless the user uses them first
- Keep replies short and professional

---

## Error handling

- If a thread has already been resolved when you try to resolve it, skip silently and continue.
- If `gh api` returns an error posting a reply, show the error and ask the user how to proceed — do not auto-retry.
- If the PR has no unresolved threads, report that immediately and stop.
- Pagination limits: `reviewThreads(first: 100)` and `comments(first: 20)` — on PRs with more than 100 review threads, or threads with more than 20 replies, results will be truncated. For PRs near these limits, process threads in batches using a comment URL instead of a PR URL.
