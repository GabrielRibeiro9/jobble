#!/usr/bin/env bash
# Roda o app injetando as variáveis do .env como --dart-define.
# Argumentos extras passam direto para o flutter: scripts/run.sh -d "iPhone 17 Pro"
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DEFINES=()
while IFS= read -r define; do
  DEFINES+=("$define")
done < <("$ROOT/scripts/dart_defines.sh")

echo "> flutter run ${DEFINES[*]-} $*"
exec flutter run ${DEFINES[@]+"${DEFINES[@]}"} "$@"
