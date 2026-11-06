---
name: git-main-mirrors-upstream
description: "In the moneyman fork, origin/main must stay an exact mirror of upstream/main; all customizations live only on the patched branch. Never fast-forward or merge patched into main."
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1a740bc7-2986-4969-bd16-68e1e4dc51b6
  modified: 2026-11-06T10:40:17.081Z
---

Keep `main` in the moneyman fork (origin = gczobel/moneyman) identical to `upstream/main` (daniel-hauser/moneyman). All customizations belong on `patched` only.

**Why:** On 2026-11-06 I was asked to "push and merge" the `patched` branch. I fast-forwarded `main` to `patched`, which pushed 8 customization commits (devcontainer, Timer.ts deletion, the config skill) onto `main`. The user said `main` should be exactly upstream. Restoring it needed a force push, which was blocked.

**Fork facts (checked with `gh repo view` and `gh run list`):**

- The fork's default branch is `patched`, not `main`.
- The scheduled Scrape (cron `5 10,22 * * *`) and Build (cron `0 6,18 * * *`) workflows run from `patched`. Scheduled runs always use the default branch.
- So `patched` is the branch that runs in production. `main` is only an upstream mirror and is not used by any schedule.

**How to apply:**

- When asked to "merge" or "push" customizations, push `patched` only. Do not merge into `main` unless the user explicitly says `main` should get those changes.
- Before any push to `main`, check `git rev-list --count upstream/main..main` (should be 0 when it mirrors upstream).
- Restoring a mirror needs a force push. Ask the user first, using `--force-with-lease` pinned to the current bad SHA.
- SSH is unavailable here; use `git -c url.https://github.com/.insteadOf=git@github.com: ...` for fetch and push.
