#!/usr/bin/env bash
#
# Transcodifica un video de la serie OpenGL a MP4 liviano para el sitio web.
#
# Uso:
#   ./tools/transcode-video.sh <numero> [salida]
#   ./tools/transcode-video.sh <archivo> [salida]
#
# Ejemplos:
#   ./tools/transcode-video.sh 3
#   ./tools/transcode-video.sh "3. Renderización triángulo.mp4"
#   ./tools/transcode-video.sh 3 parte-03.mp4
#
# Variables opcionales:
#   VIDEOS_DIR   carpeta de origen (por defecto ~/Videos/DaVinci-Resolve/OpenGLPath)
#   OUT_DIR      carpeta de destino (por defecto ~/Learning/OpenGL-Devlog/assets/video)
#   WIDTH        ancho de salida (por defecto 1920)
#   CRF          calidad, menor es mejor (por defecto 24)
#   PRESET       preset de x264 (por defecto medium)
#   AUDIO_BITRATE  bitrate de audio (por defecto 128k)
#   MAX_MB       aviso si supera este peso (por defecto 100, límite de GitHub)

set -euo pipefail

VIDEOS_DIR="${VIDEOS_DIR:-$HOME/Videos/DaVinci-Resolve/OpenGLPath}"
OUT_DIR="${OUT_DIR:-$HOME/Learning/OpenGL-Devlog/assets/video}"

WIDTH="${WIDTH:-1920}"
CRF="${CRF:-24}"
PRESET="${PRESET:-medium}"
AUDIO_BITRATE="${AUDIO_BITRATE:-128k}"
MAX_MB="${MAX_MB:-100}"

ok()   { printf "\033[0;32m[OK]\033[0m %s\n" "$1"; }
err()  { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; }
info() { printf "\033[0;36m[..]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[AVISO]\033[0m %s\n" "$1"; }

usage() {
  cat <<'EOF'
Uso:
  transcode-video.sh <numero> [salida]     busca "<numero>. ..." en VIDEOS_DIR
  transcode-video.sh <archivo> [salida]    usa una ruta de archivo

Ejemplos:
  ./tools/transcode-video.sh 3
  ./tools/transcode-video.sh "3. Renderización triángulo.mp4"
  ./tools/transcode-video.sh 3 parte-03.mp4
EOF
  exit 1
}

[ $# -ge 1 ] || usage

command -v ffmpeg >/dev/null 2>&1 || { err "ffmpeg no está instalado."; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { err "ffprobe no está instalado."; exit 1; }

arg="$1"
out_name="${2:-}"

if [[ "$arg" =~ ^[0-9]+$ ]]; then
  number="$arg"
  matches=()
  shopt -s nullglob
  for f in "$VIDEOS_DIR/$number."*; do
    case "${f,,}" in
      *.mp4|*.mov|*.mkv|*.webm|*.avi|*.m4v) matches+=("$f") ;;
    esac
  done

  if [ "${#matches[@]}" -eq 0 ]; then
    err "No encontré ningún video que empiece con \"$number.\" en $VIDEOS_DIR"
    exit 1
  fi

  if [ "${#matches[@]}" -gt 1 ]; then
    err "Hay varios videos que empiezan con \"$number.\":"
    printf '  %s\n' "${matches[@]}" >&2
    err "Pasá la ruta completa de uno para elegirlo."
    exit 1
  fi

  input="${matches[0]}"
  [ -n "$out_name" ] || out_name="$(printf 'parte-%02d.mp4' "$number")"
else
  input="$arg"
  if [ ! -f "$input" ] && [ -f "$VIDEOS_DIR/$arg" ]; then
    input="$VIDEOS_DIR/$arg"
  fi
  [ -n "$out_name" ] || out_name="$(basename "${input%.*}").mp4"
fi

[ -f "$input" ] || { err "No existe el archivo: $input"; exit 1; }

mkdir -p "$OUT_DIR"
output="$OUT_DIR/$out_name"

duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input" 2>/dev/null || echo "?")"

info "Entrada:  $input"
info "Duración: ${duration}s"
if [ -e "$output" ]; then
  warn "Se va a sobrescribir: $output"
fi

info "Transcodificando a ${WIDTH}px, CRF $CRF, preset $PRESET..."
ffmpeg -hide_banner -stats -y -i "$input" \
  -vf "scale=${WIDTH}:-2" \
  -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p \
  -c:a aac -b:a "$AUDIO_BITRATE" \
  -movflags +faststart \
  "$output"

size_out="$(stat -c %s "$output")"
max_bytes=$((MAX_MB * 1024 * 1024))

echo
ok "Listo: $output"
printf "    original: %s\n" "$(du -h "$input" | cut -f1)"
printf "    web:      %s\n" "$(du -h "$output" | cut -f1)"

if [ "$size_out" -gt "$max_bytes" ]; then
  warn "El archivo supera ${MAX_MB} MB (límite por archivo de GitHub)."
  warn "Probá con más compresión: CRF=28 PRESET=slow ./tools/transcode-video.sh ..."
fi
