#!/usr/bin/sh
HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.webm
QUALITY=90

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/lottie_common.sh && (echo | ffmpeg -y -loglevel error -r $FPS -i $TMP_PATH/%03d.png -c:v libvpx-vp9 -pix_fmt yuva420p $OUTPUT)
