---
name: cal-proxy-egress
description: How the Cal (visaCal) scrape reaches the bank from GitHub Actions: home proxy over Tailscale, repo variables, preflight. Read before touching scrape.yml, proxy-preflight.sh or browserProxy.
metadata:
  node_type: memory
  type: project
  modified: 2026-11-07
---

Cal blocks GitHub datacenter IPs, so `scrape.yml` routes the browser through a home proxy over Tailscale. The design, the reasoning and the diagram are in the Basic Memory note "moneyman: Cal blocked on GitHub Actions — problem, design and fix (2026-11)".

**Why:** Cal's Akamai returns HTML 400 "Request Rejected" to datacenter IPs. Login works, then the data API calls fail.

**How it is wired:**

- The workflow joins the tailnet as `tag:ci`, then runs `.github/scripts/proxy-preflight.sh`, then the scraper.
- The proxy name, tailnet IP and DDNS host are repo variables `PROXY_NAME`, `PROXY_IP` and `DDNS_HOST`. They are not in the code, because the repo is public. Change them with `gh variable set`.
- `MONEYMAN_CONFIG` (secret) carries `options.scraping.browserProxy`. The workflow overrides it at run time with the address the preflight verified.
- The preflight fails closed. There is no direct fallback.

**How to apply:** when debugging a Cal failure, check the preflight output first, then the proxy's access log. A 400 with HTML means the path is blocked, not that the code is wrong.

See also [[ci-secrets-and-expiry]] and [[patched-history-rewritten-2026-11-07]].
