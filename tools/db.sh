#!/usr/bin/env bash
#
# Consultas rápidas a la base de analytics en la lab (por SSH).
#
# Requiere una sola vez en la lab:
#   sudo mariadb <<'SQL'
#   CREATE USER IF NOT EXISTS 'bboeri'@'localhost' IDENTIFIED VIA unix_socket;
#   GRANT ALL PRIVILEGES ON analytics.* TO 'bboeri'@'localhost';
#   FLUSH PRIVILEGES;
#   SQL
#
# Uso: db.sh <consulta> [args]
#
#   ultimas [N]            últimas N visitas (por defecto 20)
#   articulos [días]       visitas por artículo (7)
#   dias [N]               visitas por día (30)
#   horas [días]           distribución por hora del día (7)
#   ips [días]             visitas por IP (30)
#   referrers [días]       referrers (30)
#   sesiones [días]        sesiones con tiempo total (30)
#   idiomas [días]         idiomas elegidos (30)
#   resumen                totales de todo el tiempo
#   detalle <texto> [días] visitas que contienen el texto (7)
#   borrar-ip <ip>         borra las visitas de una IP (pide confirmación)
#   sql "<consulta>"       SQL crudo (o directamente la consulta sin 'sql')
#   (sin argumentos)       shell interactiva de MariaDB
#
# Opciones:
#   --todos                no excluir las IPs de ~/.config/analytics/ignore
#
set -euo pipefail

HOST="${LAB_HOST:-boeri-lab.ddns.net}"
KEY="${LAB_KEY:-$HOME/.ssh/boeri-lab}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/analytics"

IGNORE=()
if [ -f "$CONFIG_DIR/ignore" ]; then
  while IFS= read -r line; do
    line="${line//[[:space:]]/}"
    [ -n "$line" ] && IGNORE+=("$line")
  done < "$CONFIG_DIR/ignore"
fi

usage() {
  cat <<'EOF'
Uso: db.sh <consulta> [args]

  ultimas [N]            últimas N visitas (por defecto 20)
  articulos [días]       visitas por artículo (7)
  dias [N]               visitas por día (30)
  horas [días]           distribución por hora del día (7)
  ips [días]             visitas por IP (30)
  referrers [días]       referrers (30)
  sesiones [días]        sesiones con tiempo total (30)
  idiomas [días]         idiomas elegidos (30)
  resumen                totales de todo el tiempo
  detalle <texto> [días] visitas que contienen el texto (7)
  borrar-ip <ip>         borra las visitas de una IP (pide confirmación)
  sql "<consulta>"       SQL crudo (o directamente la consulta sin 'sql')
  (sin argumentos)       shell interactiva de MariaDB

Opciones:
  --todos                no excluir las IPs de ~/.config/analytics/ignore
  -h, --help             esta ayuda
EOF
  exit 0
}

SHOW_ALL=0
POS=()
for a in "$@"; do
  case "$a" in
    --todos) SHOW_ALL=1 ;;
    -h|--help|ayuda) usage ;;
    *) POS+=("$a") ;;
  esac
done

CMD="${POS[0]:-}"

run_sql() {
  printf '%s\n' "$1" | ssh -i "$KEY" "$HOST" 'mariadb --table --default-character-set=utf8mb4 analytics'
}

num() {
  case "$1" in
    ''|*[!0-9]*) echo "Número inválido: $1" >&2; exit 1 ;;
  esac
  printf '%s' "$1"
}

valid_ip() {
  case "$1" in
    ''|*[!0-9a-fA-F:.]*) return 1 ;;
  esac
  return 0
}

excl_sql=""
if [ "$SHOW_ALL" -eq 0 ] && [ "${#IGNORE[@]}" -gt 0 ]; then
  list=""
  for ip in "${IGNORE[@]}"; do
    if ! valid_ip "$ip"; then
      echo "IP inválida en $CONFIG_DIR/ignore: $ip" >&2
      exit 1
    fi
    list="$list,'$ip'"
  done
  excl_sql=" AND ip NOT IN (${list#,})"
fi

case "$CMD" in
  ultimas)
    n="$(num "${POS[1]:-20}")"
    run_sql "SELECT DATE_FORMAT(ts,'%Y-%m-%d %H:%i') AS fecha, ip, lang,
                    title,
                    IF(duration_ms IS NULL,'-',SEC_TO_TIME(ROUND(duration_ms/1000))) AS tiempo,
                    IF(referrer='','',referrer) AS referrer
             FROM hits ORDER BY ts DESC LIMIT $n;"
    ;;

  articulos)
    d="$(num "${POS[1]:-7}")"
    run_sql "SELECT TRIM(TRAILING ' · OpenGL path from scratch' FROM
                      TRIM(TRAILING ' · Ruta OpenGL desde cero' FROM MAX(title))) AS articulo,
                    COUNT(*) AS visitas,
                    IFNULL(SEC_TO_TIME(ROUND(AVG(duration_ms)/1000)),'-') AS prom
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY path ORDER BY visitas DESC;"
    ;;

  dias)
    d="$(num "${POS[1]:-30}")"
    run_sql "SELECT DATE(ts) AS dia, COUNT(*) AS visitas
             FROM hits
             WHERE ts >= CURDATE() - INTERVAL $d DAY$excl_sql
             GROUP BY dia ORDER BY dia;"
    ;;

  horas)
    d="$(num "${POS[1]:-7}")"
    run_sql "SELECT DATE_FORMAT(ts,'%H:00') AS hora, COUNT(*) AS visitas
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY hora ORDER BY hora;"
    ;;

  ips)
    d="$(num "${POS[1]:-30}")"
    run_sql "SELECT ip, COUNT(*) AS visitas,
                    DATE_FORMAT(MAX(ts),'%Y-%m-%d %H:%i') AS ultima
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY ip ORDER BY visitas DESC;"
    ;;

  referrers)
    d="$(num "${POS[1]:-30}")"
    run_sql "SELECT IF(referrer='','(directo)',referrer) AS referrer, COUNT(*) AS visitas
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY referrer ORDER BY visitas DESC LIMIT 25;"
    ;;

  sesiones)
    d="$(num "${POS[1]:-30}")"
    run_sql "SELECT session, COUNT(*) AS paginas,
                    IFNULL(SEC_TO_TIME(ROUND(SUM(duration_ms)/1000)),'-') AS tiempo
             FROM hits
             WHERE session IS NOT NULL AND session <> ''
               AND ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY session ORDER BY SUM(duration_ms) DESC LIMIT 25;"
    ;;

  idiomas)
    d="$(num "${POS[1]:-30}")"
    run_sql "SELECT lang, COUNT(*) AS visitas
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY$excl_sql
             GROUP BY lang ORDER BY visitas DESC;"
    ;;

  resumen)
    run_sql "SELECT COUNT(*) AS visitas, COUNT(DISTINCT ip) AS ips,
                    COUNT(DISTINCT path) AS articulos,
                    IFNULL(SEC_TO_TIME(ROUND(SUM(duration_ms)/1000)),'-') AS tiempo,
                    DATE_FORMAT(MIN(ts),'%Y-%m-%d %H:%i') AS primera,
                    DATE_FORMAT(MAX(ts),'%Y-%m-%d %H:%i') AS ultima
             FROM hits WHERE 1=1$excl_sql;"
    ;;

  detalle)
    txt="${POS[1]:?falta el texto a buscar}"
    d="$(num "${POS[2]:-7}")"
    esc="${txt//\'/\'\'}"
    run_sql "SELECT DATE_FORMAT(ts,'%Y-%m-%d %H:%i') AS fecha, ip, lang,
                    IF(duration_ms IS NULL,'-',SEC_TO_TIME(ROUND(duration_ms/1000))) AS tiempo,
                    path
             FROM hits
             WHERE ts >= NOW() - INTERVAL $d DAY
               AND (path LIKE '%$esc%' OR title LIKE '%$esc%')
             ORDER BY ts DESC LIMIT 100;"
    ;;

  borrar-ip)
    ip="${POS[1]:?falta la IP}"
    if ! valid_ip "$ip"; then
      echo "IP inválida: $ip" >&2
      exit 1
    fi
    antes="$(printf "SELECT COUNT(*) FROM hits WHERE ip='%s';\n" "$ip" |
      ssh -i "$KEY" "$HOST" 'mariadb -N -B --default-character-set=utf8mb4 analytics')"
    printf 'Se van a borrar %s visitas de %s. ¿Confirmás? [s/N] ' "$antes" "$ip"
    read -r resp
    case "$resp" in
      s|S|si|sí|y|Y) ;;
      *) echo "Cancelado."; exit 0 ;;
    esac
    run_sql "DELETE FROM hits WHERE ip='$ip';"
    printf 'Borradas: %s\n' "$antes"
    ;;

  sql)
    run_sql "${POS[*]:1}"
    ;;

  "")
    ssh -t -i "$KEY" "$HOST" 'mariadb --table --default-character-set=utf8mb4 analytics'
    ;;

  *)
    run_sql "${POS[*]}"
    ;;
esac
