#!/usr/bin/sh
HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.png
QUALITY=90

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/lottie_common.sh && mv $TMP_PATH $OUTPUT
