HEIGHT=512
WIDTH=512
FPS=50
OUTPUT_EXTENSION=.gif
QUALITY=90

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/tgs_common.sh && gifski --quiet -o $OUTPUT --fps $FPS --height $HEIGHT --width $WIDTH --quality $QUALITY $PNG_FILES
