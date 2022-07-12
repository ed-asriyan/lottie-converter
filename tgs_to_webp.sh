HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.webp
QUALITY=90

source tgs_to_png.sh && img2webp -lossy -d $((1000 / $FPS)) $(find $PNG_PATH -type f -name '*.png') -o $OUTPUT -q $QUALITY
