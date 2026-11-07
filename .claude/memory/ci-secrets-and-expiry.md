---
name: ci-secrets-and-expiry
description: GitHub secrets and variables the Scrape workflow depends on, and when the Tailscale auth key expires. Read when a scrape fails at the tailnet join or when changing config.
metadata:
  node_type: memory
  type: reference
  modified: 2026-11-07
---

Secrets and variables in `gczobel/moneyman` used by `scrape.yml`:

- `MONEYMAN_CONFIG` (secret): the whole config as one-line JSON, including `browserProxy`. Update with `gh secret set MONEYMAN_CONFIG -R gczobel/moneyman < file`.
- `TS_AUTHKEY` (secret): Tailscale auth key, Reusable and Ephemeral, tag `tag:ci`. **Expires about 2027-02-05.** Regenerate it in the Tailscale admin console before then and set it again with `gh secret set TS_AUTHKEY`.
- `PROXY_NAME`, `PROXY_IP`, `DDNS_HOST` (variables): the proxy addresses. Not secret, but kept out of the public code.

**How to apply:** if the tailnet join step fails on an otherwise healthy run, check `TS_AUTHKEY` expiry first. The Tailscale action version is pinned in the workflow, and the client it installs is old (1.82.0 in the run).
