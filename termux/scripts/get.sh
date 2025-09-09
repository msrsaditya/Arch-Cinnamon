#!/usr/bin/env bash
set -euo pipefail
folder="${1:-${HOME}}"
port=64943
mkdir -p "${folder}"
nc -l -w 60 "${port}" | {
  IFS= read -r file
  if [[ -z "${file}" ]]; then
    tar --no-same-owner --warning=no-unknown-keyword --blocking-factor=8192 -xpf - -C "${folder}"
  else
    cat > "${folder}/${file}"
  fi
}
