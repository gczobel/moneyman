# Fork sync & customization design

## Context

This fork (`gczobel/moneyman`, upstream `daniel-hauser/moneyman`) had accumulated divergence from upstream through merge commits and a `merge=ours` git-attributes strategy that permanently overrides certain files on every merge, silently discarding any upstream changes to them. A prior repo audit (`REPO-STATUS.md`) found the fork 2 commits ahead / 4 behind upstream, a stale branch (`fix/yahav-patch`) and stash duplicating work already superseded in the working tree, and a same-filename collision between two unrelated scraper patches.

The goal isn't to build tooling to manage divergence — it's to shrink the divergence itself so there's little left to manage. Reviewing what the fork actually needs on top of upstream to run:

- Patches to the `israeli-bank-scrapers` dependency (yahav, isracard) and the scripts that apply them — all **new files** upstream doesn't have, so they never conflict with an upstream sync.
- `CLAUDE.md` / `CUSTOMIZATION.md` — also new files.
- A single line in `package.json` (`postinstall`) to wire in the patch-application script — the only genuine content change to an existing upstream-tracked file.
- `.vscode/launch.json` — a personal debug config with no bearing on the built image or the Scrape Action. Not needed in git at all.

With `.vscode/launch.json` moved out of tracking, divergence from upstream reduces to: a handful of new files, plus one changed line in `package.json`. That's small enough to sync with a plain `git merge upstream/main`, no rebase machinery or permanent per-file override rules required.

Config/credential handling and the GitHub-secret rotation workflow are explicitly out of scope for this design — separate follow-up.

## Target end state

- `main` merged up to date with `upstream/main` (currently 4 commits behind).
- Tracked fork additions (unchanged in kind, cleaned up in content):
  - `patches/israeli-bank-scrapers+6.7.3.patch` — yahav-only (current working-tree content), verified it still applies against the installed `6.7.5`.
  - `patches/israeli-bank-scrapers+6.7.3+isracard.patch` — isracard login-delay hunk.
  - Remove `patches/israeli-bank-scrapers+6.7.3+yahav.patch` (byte-identical duplicate of the base-named patch — redundant).
  - `scripts/apply-patches.js`, `src/scripts/config-to-single-line.ts` — committed as-is.
  - `visa-cal-change-password-fix.md`, `yahav-statement-options-fix.md` — committed as reference docs; the visa-cal fix itself stays a documented TODO, not implemented in this pass.
  - `CLAUDE.md` — already tracked, no change needed.
  - `CUSTOMIZATION.md` — rewritten to list current customizations accurately (drops the stale `scrape.yml` claim, adds the patch pipeline) and describes a plain-merge sync (no more conflict-resolution runbook for `merge=ours` files).
- `package.json` — keep the one-line `postinstall` change (already staged).
- `.vscode/launch.json` — removed from git tracking, added to `.gitignore`. The staged improvements to it (the new debug config, `MONEYMAN_CONFIG_PATH`) stay on disk, just untracked.
- `.gitattributes` — drop the `merge=ours` block entirely; nothing left needs it once `.vscode/launch.json` is untracked and `CLAUDE.md`/`CUSTOMIZATION.md` are new-file additions upstream can't conflict with.
- `fix/yahav-patch` branch and `stash@{0}` — deleted (confirmed superseded by the working-tree patch content, per the earlier audit).
- Untracked credential-bearing files (`config.json`, `config copy.json`, `configsingle.json`, `output.json`) — added to `.gitignore` now (safety fix from the audit), left in place on disk; their workflow is the separate follow-up design.

## Sync procedure

1. `git fetch upstream`
2. `git merge upstream/main` — expect a clean merge given the minimal divergence; the only plausible conflict point is `package.json`, and only if upstream also touched the `postinstall` line.
3. Apply the file-tracking changes above (gitignore updates, patch cleanup, `CUSTOMIZATION.md` rewrite, `.gitattributes` cleanup) as a following commit.
4. Delete `fix/yahav-patch` (local + remote) and drop the stash.

## Verification

- `npm ci` — confirms `patch-package` + `scripts/apply-patches.js` apply cleanly against the currently-installed `israeli-bank-scrapers@6.7.5`.
- `npm run build && npm test` — fast local smoke gate before pushing.
- End-to-end: push to `origin/main`, then the user manually triggers the "Scrape" GitHub Action (`workflow_dispatch`) against real accounts and checks the run — this is the real verification, not local tests.

## Out of scope

- Config/credential storage and GitHub-secret rotation workflow (separate design).
- Implementing the visa-cal change-password fix (stays a design doc).
- Any scheduled/automated sync bot — divergence is small enough now that manual `git fetch upstream && git merge upstream/main` is sufficient; revisit only if that stops being true.
