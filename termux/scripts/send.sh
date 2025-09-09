#!/usr/bin/env bash
set -euo pipefail
path="${1}"
ip="${2}"
port=64943
flags=(-f -b -t -r -a -p -i 0.5 -e --si -B 8M)
if [[ ! -e "${path}" ]]; then
  echo "Error: Path Not Found => ${path}" >&2
  exit 1
fi
if ! [[ "${ip}" =~ ^[0-9.]+$ ]]; then
  echo "Error: Invalid IP format => ${ip}" >&2
  exit 1
fi
lastpart=$(basename "${path}")
if [[ -d "${path}" ]]; then
  size=$(du -sb "${path}")
  bytes=${size%%[[:space:]]*}
  parentdir=$(dirname "${path}")
  stream() {
    printf "\n"
    tar --blocking-factor=8192 --exclude='._*' --exclude='.DS_Store' -cpf - -C "${parentdir}" "${lastpart}"
  }
else
  bytes=$(stat -c%s "${path}")

  stream() {
    printf "%s\n" "${lastpart}"
    cat "${path}"
  }
fi
stream | pv "${flags[@]}" -s "${bytes}" | nc -N "${ip}" "${port}"
