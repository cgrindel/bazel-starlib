#!/usr/bin/env bash

src="$1"
out="$2"
header="$3"

first_line=$(head -n 1 "${src}")
if [[ "${first_line}" != "${header}"  ]]; then
  echo "${header}" > "${out}"
fi
cat "${src}" >> "${out}"
