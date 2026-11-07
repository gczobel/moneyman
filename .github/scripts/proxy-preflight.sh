#!/usr/bin/env bash
# Egress preflight for the Cal scrape. Fails closed: it exits non-zero unless the
# proxy leaves from the home line, and it never falls back to a direct connection.
#
# Usage: proxy-preflight.sh <moneyman-image>
# On success it writes "proxy=<url>" to $GITHUB_OUTPUT.
#
# IP addresses are never printed: this repo is public and the home IP should not
# appear in its logs.
set -uo pipefail

IMAGE="${1:?usage: proxy-preflight.sh <moneyman-image>}"
# Proxy addresses and the DDNS host come from repository variables, so they are not
# stored in this public repo: PROXY_NAME (URL), PROXY_IP (URL), DDNS_HOST (host name).
PROXY_NAME="${PROXY_NAME:?set the PROXY_NAME repository variable}"
PROXY_IP="${PROXY_IP:?set the PROXY_IP repository variable}"
DDNS_HOST="${DDNS_HOST:?set the DDNS_HOST repository variable}"
TAILNET_HOST="${PROXY_NAME#*://}"
TAILNET_HOST="${TAILNET_HOST%%:*}"
CURL_IMAGE="curlimages/curl:8.11.1"

fail() {
  echo "::error::Proxy preflight failed: $*" >&2
  exit 1
}

log() {
  echo "[preflight] $*"
}

# Retry a command: retry <attempts> <seconds between attempts> <command...>
retry() {
  local attempts=$1 wait=$2 i
  shift 2
  for ((i = 1; i <= attempts; i++)); do
    if "$@"; then
      return 0
    fi
    if ((i < attempts)); then
      sleep "$wait"
    fi
  done
  return 1
}

# Check 0: pick the proxy address. Use the MagicDNS name only if the scraper's own
# container can resolve it; otherwise use the tailnet IP.
if docker run --rm --entrypoint node "$IMAGE" \
  -e 'require("dns").lookup(process.argv[1], e => process.exit(e ? 1 : 0))' \
  "$TAILNET_HOST" >/dev/null 2>&1; then
  PROXY="$PROXY_NAME"
  log "proxy address: MagicDNS name (resolves inside the container)"
else
  PROXY="$PROXY_IP"
  log "proxy address: tailnet IP (name does not resolve inside the container)"
fi

proxied_ip() {
  curl -fsS --max-time 10 -x "$PROXY" https://api.ipify.org 2>/dev/null
}

direct_ip() {
  curl -fsS --max-time 10 --noproxy '*' https://api.ipify.org 2>/dev/null
}

ddns_ip() {
  getent ahostsv4 "$DDNS_HOST" | awk 'NR == 1 { print $1 }'
}

# Checks 1 and 2: the proxied IP must equal the DDNS A record. The record lags a
# little after the home IP changes, so retry for about 2.5 minutes.
ip_matches_ddns() {
  local proxied ddns
  proxied="$(proxied_ip)" || return 1
  ddns="$(ddns_ip)" || return 1
  [[ -n "$proxied" && -n "$ddns" && "$proxied" == "$ddns" ]]
}
if ! retry 10 15 ip_matches_ddns; then
  fail "proxied IP does not match the DDNS record for $DDNS_HOST after retries"
fi
log "check 1+2 ok: proxied IP matches the DDNS record"

PROXIED="$(proxied_ip)" || fail "could not reach ipify through the proxy"

# Check 3: the proxied IP must differ from the runner's own (direct) IP.
DIRECT="$(direct_ip)" || fail "could not read the runner's direct IP"
if [[ "$PROXIED" == "$DIRECT" ]]; then
  fail "proxied IP equals the runner's direct IP, so the traffic is not using the proxy"
fi
log "check 3 ok: proxied IP differs from the runner's direct IP"

# Check 4: the proxied country must be IL.
COUNTRY="$(curl -fsS --max-time 10 -x "$PROXY" https://ipinfo.io/country 2>/dev/null | tr -d '[:space:]')" || true
if [[ "$COUNTRY" != "IL" ]]; then
  fail "proxied country is not IL"
fi
log "check 4 ok: proxied country is IL"

# Check 5: the same proxied request must work from inside a docker run container,
# on the default bridge network that the scraper uses. Bridge traffic to 100.x may
# not route through the host, so this is tested separately.
in_container_ip() {
  docker run --rm "$CURL_IMAGE" -fsS --max-time 10 -x "$PROXY" https://api.ipify.org 2>/dev/null
}
CONTAINER_IP="$(retry 3 10 in_container_ip)" || fail "proxied request failed from inside a docker run container"
if [[ "$CONTAINER_IP" != "$PROXIED" ]]; then
  fail "proxied IP from inside the container differs from the host"
fi
log "check 5 ok: proxied request works from inside a docker run container"

echo "proxy=$PROXY" >> "$GITHUB_OUTPUT"
log "all checks passed"
