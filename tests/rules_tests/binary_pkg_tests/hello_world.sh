#!/usr/bin/env bash

echo "Hello, World!"
echo "Args Count: ${#}"
for (( i = 1; i < ${#}; i++ )); do
  echo "Arg ${i}: ${!i}"
done
