HEIGHT=512
WIDTH=512
FPS=50
OUTPUT_EXTENSION=.gif
QUALITY=90

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

source $SCRIPT_DIR/tgs_to_png.sh && gifski --quiet -o $OUTPUT --fps $FPS --height $HEIGHT --width $WIDTH --quality $QUALITY $PNG_FILES
