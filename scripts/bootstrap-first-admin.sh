#!/bin/bash
# Bootstraps the first administrator account by POSTing the definition from
# first-admin.json to the local admin API. Run once against a fresh instance.
#
# By default targets Core running directly from the IDE (default: http://localhost:8080).
# The Local API answers only requests from Core's own localhost, so for a Core running
# via docker compose call it with docker exec instead (see the README).

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ILM_HOST="http://localhost:8080"

while [[ $# -gt 0 ]]; do
  case $1 in
    --ilm-host) ILM_HOST="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; echo "Usage: $0 [--ilm-host URL]"; exit 1 ;;
  esac
done

curl -fsS -X POST -H 'content-type: application/json' \
  -d "@${SCRIPT_DIR}/first-admin.json" \
  "${ILM_HOST}/api/v1/local/admins"
