HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.webp
QUALITY=75

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/tgs_common.sh && img2webp -lossy -d $((1000 / $FPS)) -q $QUALITY $PNG_FILES -o $OUTPUT
