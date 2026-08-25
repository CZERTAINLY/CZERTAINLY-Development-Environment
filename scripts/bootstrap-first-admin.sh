#!/bin/bash
# Bootstraps the first administrator account by POSTing the definition from
# first-admin.json to the local admin API. Run once against a fresh instance.
#
# By default targets Core running directly from the IDE (default: http://localhost:8080).
# The Local API answers only requests from Core's own localhost, so for a Core running
# via docker compose call it with docker exec instead (see the README).
#
# By default the administrator is registered with the dummy certificate bundled in
# first-admin.json. Pass --client-cert-pem to register your own certificate instead, so that
# the account can be used by tooling that authenticates with it.

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ILM_HOST="http://localhost:8080"
CLIENT_CERT_PEM=""

usage() {
  echo "Usage: $0 [--ilm-host URL] [--client-cert-pem FILE]"
  exit "${1:-1}"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --ilm-host)        ILM_HOST="$2"; shift 2 ;;
    --client-cert-pem) CLIENT_CERT_PEM="$2"; shift 2 ;;
    --help|-h)         usage 0 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$CLIENT_CERT_PEM" ]]; then
  curl -fsS -X POST -H 'content-type: application/json' \
    -d "@${SCRIPT_DIR}/first-admin.json" \
    "${ILM_HOST}/api/v1/local/admins"
  exit
fi

[[ -f "$CLIENT_CERT_PEM" ]] || { echo "ERROR: certificate not found: $CLIENT_CERT_PEM" >&2; exit 1; }
command -v jq &>/dev/null || { echo "ERROR: jq is required for --client-cert-pem" >&2; exit 1; }

# Take the base64 body of the first certificate only.
CERTIFICATE_DATA=$(awk '/-----BEGIN CERTIFICATE-----/ { body = 1; next }
                        /-----END CERTIFICATE-----/   { exit }
                        body' "$CLIENT_CERT_PEM" | tr -d '\n\r')
[[ -n "$CERTIFICATE_DATA" ]] || { echo "ERROR: no certificate block found in $CLIENT_CERT_PEM" >&2; exit 1; }

jq --arg certificate "$CERTIFICATE_DATA" '.certificateData = $certificate' "${SCRIPT_DIR}/first-admin.json" \
  | curl -fsS -X POST -H 'content-type: application/json' \
      --data-binary @- \
      "${ILM_HOST}/api/v1/local/admins"
