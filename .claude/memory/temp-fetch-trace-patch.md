---
name: temp-fetch-trace-patch
description: patches/israeli-bank-scrapers+6.12.2.patch contains temporary fetch trace logging on top of the upstream Cal PR 1193. Read before upgrading israeli-bank-scrapers or changing that patch.
metadata:
  node_type: memory
  type: project
  modified: 2026-11-07
---

The patch `patches/israeli-bank-scrapers+6.12.2.patch` does two things:

1. It applies upstream PR eshaham/israeli-bank-scrapers#1193 to `lib/scrapers/visa-cal.js`. This moves Cal's API calls into the logged-in browser page. Keep this part while Cal is scraped through the proxy, until the PR is merged upstream.
2. It adds temporary trace logging to `lib/helpers/fetch.js`, under the debug namespace `israeli-bank-scrapers:fetch-trace`. Remove this part once the Cal path is stable.

**How to apply:**

- To remove only the trace logging, regenerate the patch from a clean 6.12.2 package with just the PR 1193 change.
- When upgrading israeli-bank-scrapers, check whether PR 1193 has been merged. If it has, drop the patch and use the release instead.
- `patch-package` runs on `npm ci`, and the Dockerfile copies `patches/`, so the patch reaches the image.
