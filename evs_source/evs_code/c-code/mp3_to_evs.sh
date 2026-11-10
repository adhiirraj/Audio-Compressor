
#!/usr/bin/env bash
set -Eeuo pipefail

# EVS configuration
BITRATE=13200
SAMPLE_RATE=16000
FS=16

# Locate the official EVS binaries beside this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EVS_COD="$SCRIPT_DIR/EVS_cod"
EVS_DEC="$SCRIPT_DIR/EVS_dec"

# Validate arguments
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 input.mp3 [output_name]"
    exit 1
fi

INPUT="$(realpath "$1")"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file not found: $INPUT"
    exit 1
fi

for cmd in ffmpeg paplay; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

for bin in "$EVS_COD" "$EVS_DEC"; do
    if [[ ! -x "$bin" ]]; then
        echo "Error: EVS binary missing or not executable: $bin"
        exit 1
    fi
done

# Output filenames
NAME="${2:-$(basename "${INPUT%.*}")}"
BITSTREAM="${NAME}.192"
WAV="${NAME}_evs.wav"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

PCM_INPUT="$TEMP_DIR/input.16k"
PCM_OUTPUT="$TEMP_DIR/decoded.16k"

echo "=================================="
echo "       MP3 TO EVS CONVERTER"
echo "=================================="
echo "Input:   $INPUT"
echo "Bitrate: $BITRATE bps"
echo "Rate:    ${SAMPLE_RATE} Hz"
echo

# Step 1: MP3 -> raw PCM
echo "[1/4] Converting MP3 to raw PCM..."

ffmpeg -hide_banner -loglevel error -y \
    -i "$INPUT" \
    -ar "$SAMPLE_RATE" \
    -ac 1 \
    -c:a pcm_s16le \
    -f s16le \
    "$PCM_INPUT"

# Step 2: PCM -> EVS bitstream
echo "[2/4] Encoding with EVS..."

"$EVS_COD" "$BITRATE" "$FS" "$PCM_INPUT" "$BITSTREAM"

# Step 3: EVS -> raw PCM
echo "[3/4] Decoding EVS for playback..."

"$EVS_DEC" "$FS" "$BITSTREAM" "$PCM_OUTPUT"

# Step 4: Raw PCM -> WAV
echo "[4/4] Creating WAV file..."

ffmpeg -hide_banner -loglevel error -y \
    -f s16le \
    -ar "$SAMPLE_RATE" \
    -ac 1 \
    -i "$PCM_OUTPUT" \
    -c:a pcm_s16le \
    "$WAV"

echo
echo "=================================="
echo "          CONVERSION DONE"
echo "=================================="
echo "EVS bitstream: $BITSTREAM"
echo "Playback WAV:  $WAV"
echo

# Play reconstructed audio
if command -v paplay >/dev/null 2>&1; then
    echo "Playing reconstructed audio..."
    paplay "$WAV"
fi

echo "Finished."
