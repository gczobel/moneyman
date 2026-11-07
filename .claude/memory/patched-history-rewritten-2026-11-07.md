---
name: patched-history-rewritten-2026-11-07
description: patched and the old feat/proxy-egress branch were force-pushed on 2026-11-07 to remove the proxy host values from git history. Old SHAs are invalid. Read if a commit SHA from before that date does not resolve.
metadata:
  node_type: memory
  type: project
  modified: 2026-11-07
---

On 2026-11-07, `patched` was force-pushed to remove the proxy name, tailnet IP and DDNS host from the commits that had added them. The values were replaced with placeholders in history.

**Commit SHAs changed:** `patched` moved from `e7c3de3` to `041da53`. Every commit after the affected one got a new SHA, including the merge commits. The branch `feat/proxy-egress` was rewritten and then deleted, since its content was already in `patched`.

**Why:** the repo is public and the values should not be readable there. Replacing them in the latest file alone does not remove them from history.

**How to apply:**

- A pre-2026-11-07 SHA from notes, Actions run links or issues will not resolve on `patched`. Look it up by message instead.
- Clones made before the rewrite still hold the old history. Re-sync them with `git fetch && git reset --hard origin/patched`, after checking for local work.
- Never force-push `patched` again without confirming with the user first.
