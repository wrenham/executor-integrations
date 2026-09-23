#!/usr/bin/env sh
# Regenerate openapi.sandbox.yaml from openapi.yaml. Run after every edit to the spec.
set -eu
cd "$(dirname "$0")"
sed \
  -e 's#https://api\.freeagent\.com/v2#https://api.sandbox.freeagent.com/v2#g' \
  -e 's#^  title: FreeAgent API$#  title: FreeAgent API (sandbox)#' \
  -e 's#^    description: Production$#    description: Sandbox#' \
  openapi.yaml > openapi.sandbox.yaml
echo "wrote openapi.sandbox.yaml"
