# MP3 to EVS audio compression
Converts an audio file, compresses it using EVS (Enhanced Voice Services) Codec used in delivering high-fidelity audio over modern mobile networks. \
Simulates what your audio will sound like in a call. \
`git clone https://github.com/adhiirraj/Audio-Compressor` \
`cd AudioCompressor` \
`sudo apt update` \
`sudo apt install -y build-essential gcc make ffmpeg pulseaudio-utils unzip` \
`./convert_to_evs.sh input.mp3` \
Output would be
1. input.192 which is the compressed EVS bitstream.
2. input_evs.wav which is the reconstructed audio for playback.
