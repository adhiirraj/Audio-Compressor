#!/usr/bin/env bash
set -Eeuo pipefail

# Launcher for the EVS converter.
# Keep this file in ~/Audio Compressor and keep the actual converter
# in ~/evs_source/evs_code/c-code/mp3_to_evs.sh.

CONVERTER="$HOME/evs_source/evs_code/c-code/mp3_to_evs.sh"

if [[ ! -f "$CONVERTER" ]]; then
    echo "Error: EVS converter script not found:"
    echo "  $CONVERTER"
    echo
    echo "Make sure mp3_to_evs.sh is saved in:"
    echo "  ~/evs_source/evs_code/c-code/"
    exit 1
fi

if [[ ! -x "$CONVERTER" ]]; then
    echo "Making the EVS converter executable..."
    chmod +x "$CONVERTER"
fi

if [[ $# -eq 0 ]]; then
    echo "Usage:"
    echo "  ./convert_to_evs.sh input.mp3 [output_name]"
    echo
    echo "Example:"
    echo "  ./convert_to_evs.sh song.mp3 song_evs"
    exit 1
fi

exec "$CONVERTER" "$@"

