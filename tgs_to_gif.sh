HEIGHT=512
WIDTH=512
FPS=50
OUTPUT_EXTENSION=.gif
QUALITY=90

source tgs_to_png.sh && gifski --quiet -o $OUTPUT --fps $FPS --height $HEIGHT --width $WIDTH --quality $QUALITY $(find $PNG_PATH -type f -name '*.png')
