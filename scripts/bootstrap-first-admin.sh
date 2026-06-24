#!/bin/bash
# Bootstraps the first administrator account by POSTing the definition from
# first-admin.json to the local admin API. Run once against a fresh instance.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "$SCRIPT_DIR"

curl -X POST -H 'content-type: application/json' -d "@${SCRIPT_DIR}/first-admin.json" http://localhost:8080/api/v1/local/admins
