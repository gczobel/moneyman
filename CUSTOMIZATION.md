# Customizations

This fork (`gczobel/moneyman`) tracks upstream (`daniel-hauser/moneyman`) via plain merges. The customizations below are almost entirely **additive files** that upstream doesn't have, so they never conflict with an upstream sync. Only one existing upstream file has a real content change.

## What's customized

- `patches/israeli-bank-scrapers+6.7.3.patch` — fixes for the Yahav bank scraper's date-picker and account-ID selectors, which broke against the live site ahead of an upstream fix landing (see `yahav-statement-options-fix.md`).
- `patches/israeli-bank-scrapers+6.7.3+isracard.patch` — adds a randomized delay before Isracard/Amex login to reduce bot-detection false positives.
- `scripts/apply-patches.js` — applies named-variant patches (`{package}+{version}+{label}.patch`) via `git apply` after `patch-package` runs. `patch-package` only auto-applies the plain `{package}+{version}.patch` form, so named variants need this extra step.
- `src/scripts/config-to-single-line.ts` — minifies a local JSONC config file into a single-line JSON string, for pasting into the `MONEYMAN_CONFIG` GitHub Actions secret.
- `visa-cal-change-password-fix.md` — a documented, **not yet implemented** fix for Cal's changed password-change error UI. No patch file exists for it yet.
- `yahav-statement-options-fix.md` — postmortem explaining the root cause behind the Yahav patch above.
- `package.json` — `postinstall` runs `patch-package && node scripts/apply-patches.js` instead of just `patch-package`, to wire in the named-patch mechanism.

`.vscode/launch.json` is **not** tracked — it's a personal debug config with no effect on the built image or CI, so it's gitignored and stays local-only per machine.

## Syncing with upstream

Divergence is small enough that a plain merge works — no rebase, no `merge=ours`, no conflict runbook needed for most files:

```bash
git remote add upstream git@github.com:daniel-hauser/moneyman.git  # once
git fetch upstream
git merge upstream/main
```

The only file where a real conflict is plausible is `package.json`'s `postinstall` line — if it conflicts, keep the `patch-package && node scripts/apply-patches.js` form and reconcile with whatever upstream changed around it.

After merging:

```bash
npm ci        # re-applies patches via postinstall
npm run build
npm test
```

Then push, and verify end-to-end by manually running the "Scrape" GitHub Action (`workflow_dispatch`) against real accounts.

## Adding a new scraper patch

1. Edit the relevant file under `node_modules/israeli-bank-scrapers/lib/scrapers/`.
2. Generate the patch: `npx patch-package israeli-bank-scrapers` (plain fixes) — or, for a named variant that shouldn't be picked up automatically by `patch-package`, hand-craft `patches/israeli-bank-scrapers+<version>+<label>.patch` and let `scripts/apply-patches.js` apply it.
3. Commit the patch file.
