#!/usr/bin/env bash
# Lê um arquivo .env e imprime um --dart-define por linha.
# Uso: DEFINES=(); while IFS= read -r d; do DEFINES+=("$d"); done < <(scripts/dart_defines.sh)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "aviso: $ENV_FILE não encontrado; usando os defaults de AppConfig" >&2
  exit 0
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line#"${line%%[![:space:]]*}"}"          # trim à esquerda
  [[ -z "$line" || "$line" == \#* ]] && continue
  line="${line#export }"
  [[ "$line" != *=* ]] && continue

  key="${line%%=*}"
  value="${line#*=}"
  key="${key//[[:space:]]/}"
  value="${value%"${value##*[![:space:]]}"}"        # trim à direita
  # remove aspas simples ou duplas envolvendo o valor
  if [[ "$value" == \"*\" || "$value" == \'*\' ]]; then
    value="${value:1:${#value}-2}"
  fi
  [[ -z "$key" || -z "$value" ]] && continue

  printf -- '--dart-define=%s=%s\n' "$key" "$value"
done < "$ENV_FILE"
