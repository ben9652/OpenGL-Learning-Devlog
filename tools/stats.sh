#!/usr/bin/env bash
#
# Estadísticas del devlog (API propia en boeri-lab).
#
# Uso:
#   ./tools/stats.sh [--detalle] [--days N] [--start YYYY-MM-DD] [--end YYYY-MM-DD]
#                    [--exclude-ip IP[,IP...]] [--url URL]
#
# Token: $ANALYTICS_TOKEN o ~/.config/analytics/token
# Las IPs a excluir siempre se pueden dejar en ~/.config/analytics/ignore (una por línea).

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/analytics"
URL="${ANALYTICS_URL:-https://boeri-lab.ddns.net/analytics/stats}"
TOKEN="${ANALYTICS_TOKEN:-}"

[ -n "$TOKEN" ] || [ ! -f "$CONFIG_DIR/token" ] || TOKEN="$(tr -d '[:space:]' < "$CONFIG_DIR/token")"

DAYS=7
START=""
END=""
DETAIL=0
EXCLUDE=()

if [ -f "$CONFIG_DIR/ignore" ]; then
  while IFS= read -r line; do
    line="$(printf '%s' "$line" | tr -d '[:space:]')"
    [ -n "$line" ] && EXCLUDE+=("$line")
  done < "$CONFIG_DIR/ignore"
fi

usage() {
  cat <<'EOF'
Uso: stats.sh [opciones]

Opciones:
  --detalle            lista cada visita (fecha, hora, IP, idioma, referrer)
  --days N             últimos N días (por defecto 7)
  --start FECHA        fecha inicial (YYYY-MM-DD)
  --end FECHA          fecha final (YYYY-MM-DD)
  --exclude-ip LISTA   IPs a no contar (separadas por coma; repetible)
  --url URL            endpoint de stats (por defecto el de boeri-lab)
  -h, --help           esta ayuda

Configuración:
  Token:  $ANALYTICS_TOKEN  o  ~/.config/analytics/token
  IPs ignoradas:  ~/.config/analytics/ignore (una por línea)
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --detalle) DETAIL=1; shift ;;
    --days) DAYS="${2:?falta N}"; shift 2 ;;
    --start) START="${2:?falta fecha}"; shift 2 ;;
    --end) END="${2:?falta fecha}"; shift 2 ;;
    --exclude-ip) EXCLUDE+=("${2:?falta IP}"); shift 2 ;;
    --url) URL="${2:?falta URL}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Opción desconocida: $1" >&2; usage ;;
  esac
done

if ! command -v curl >/dev/null 2>&1; then
  echo "Falta curl." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Falta jq." >&2
  exit 1
fi

if [ -z "$TOKEN" ]; then
  cat <<EOF
Falta el token de la API de analytics.

   mkdir -p "$CONFIG_DIR"
   printf '%s' 'TU_TOKEN' > "$CONFIG_DIR/token"
EOF
  exit 1
fi

END="${END:-$(date +%F)}"
if [ -z "$START" ]; then
  START="$(date -d "$END -$((DAYS - 1)) days" +%F)"
fi

args=(-sS -G -H "Authorization: Bearer $TOKEN"
      --data-urlencode "start=$START"
      --data-urlencode "end=$END")
if [ "$DETAIL" -eq 1 ]; then
  args+=(--data-urlencode "detail=1")
fi
for ip in ${EXCLUDE[@]+"${EXCLUDE[@]}"}; do
  args+=(--data-urlencode "exclude_ip=$ip")
done

json="$(curl "${args[@]}" "$URL")" || {
  echo "Error consultando $URL" >&2
  exit 1
}

if ! jq -e '.total != null' <<<"$json" >/dev/null 2>&1; then
  echo "Respuesta inesperada de la API:" >&2
  printf '%s\n' "$json" >&2
  exit 1
fi

bar() {
  local n="$1"
  if [ "$n" -gt 0 ]; then
    printf '%*s' "$n" '' | tr ' ' '#'
  fi
}

print_rows() {
  local max=0 count label width=44 line
  local rows=()

  while IFS= read -r line; do
    if [ -n "$line" ]; then
      count="${line%%$'\t'*}"
      label="${line#*$'\t'}"
      rows+=("$count"$'\t'"$label")
      if [ "$count" -gt "$max" ]; then
        max="$count"
      fi
    fi
  done

  if [ "${#rows[@]}" -eq 0 ]; then
    printf '   (sin datos)\n'
    return 0
  fi

  for line in "${rows[@]}"; do
    count="${line%%$'\t'*}"
    label="${line#*$'\t'}"
    if [ "$max" -gt 0 ]; then
      local len=$((count * 20 / max))
      if [ "$len" -lt 1 ] && [ "$count" -gt 0 ]; then
        len=1
      fi
    else
      local len=0
    fi
    printf '   %5d  %-*.*s  %s\n' "$count" "$width" "$width" "$label" "$(bar "$len")"
  done
}

hr() {
  printf '%s\n' '────────────────────────────────────────────────────────────'
}

hr
printf ' Analytics · %s → %s\n' "$START" "$END"
if [ "${#EXCLUDE[@]}" -gt 0 ]; then
  printf ' Excluyendo: %s\n' "${EXCLUDE[*]}"
fi
hr

printf '\n RESUMEN\n'
printf '   visitas: %s\n' "$(jq -r '.total' <<<"$json")"

printf '\n POR DÍA\n'
jq -r '.by_day[]? | "\(.count)\t\(.name)"' <<<"$json" | print_rows

printf '\n POR HORA\n'
jq -r '.by_hour[]? | "\(.count)\t\(.name):00"' <<<"$json" | print_rows

printf '\n ARTÍCULOS\n'
jq -r '
  def limpio: sub(" · (OpenGL path from scratch|Ruta OpenGL desde cero)$"; "");
  .by_path[]?
  | "\(.count)\t\(if (.title // "") != "" then (.title | limpio) else .path end)"
' <<<"$json" | print_rows

printf '\n IPS\n'
jq -r '.by_ip[]? | "\(.count)\t\(.name)"' <<<"$json" | print_rows

printf '\n REFERRERS\n'
jq -r '.by_referrer[]? | select(.name != "") | "\(.count)\t\(.name)"' <<<"$json" | print_rows

if [ "$DETAIL" -eq 1 ]; then
  printf '\n DETALLE DE VISITAS\n'
  jq -r '
    def limpio: sub(" · (OpenGL path from scratch|Ruta OpenGL desde cero)$"; "");
    .visits
    | group_by(.path)
    | map({
        title: ((.[0].title // "") | limpio),
        path: .[0].path,
        rows: (sort_by(.ts) | reverse)
      })
    | sort_by(-(.rows | length))
    | .[]
    | "\n   \(.title)  (\(.rows | length))",
      (.rows[] | "     \(.ts)  \(.ip)  [\(.lang)]\(if .referrer != "" then "  ref: \(.referrer)" else "" end)")
  ' <<<"$json"
fi

echo
