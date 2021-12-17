#!/usr/bin/env bash

set -euo pipefail

args_count=($# - 1)
echo "Args Count: ${args_count}"
for (( i = 1; i <= ${#}; i++ )); do
  echo "  ${i}: ${!i}"
done
