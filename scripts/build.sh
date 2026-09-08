#!/usr/bin/env bash
# Compila o app injetando as variáveis do .env como --dart-define.
# Uso: scripts/build.sh ios --release   |   scripts/build.sh apk --release
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ $# -eq 0 ]]; then
  echo "uso: scripts/build.sh <alvo> [flags do flutter]" >&2
  echo "exemplo: scripts/build.sh ios --release" >&2
  exit 1
fi

DEFINES=()
while IFS= read -r define; do
  DEFINES+=("$define")
done < <("$ROOT/scripts/dart_defines.sh")

echo "> flutter build $* ${DEFINES[*]-}"
exec flutter build "$@" ${DEFINES[@]+"${DEFINES[@]}"}
