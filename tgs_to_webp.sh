HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.webp
QUALITY=90

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

source $SCRIPT_DIR/tgs_to_png.sh && img2webp -lossy -d $((1000 / $FPS)) $PNG_FILES -o $OUTPUT -q $QUALITY
