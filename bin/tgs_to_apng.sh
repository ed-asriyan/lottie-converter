HEIGHT=512
WIDTH=512
FPS=60
OUTPUT_EXTENSION=.apng
QUALITY=90

SCRIPT_DIR=$(dirname "$0")

source $SCRIPT_DIR/tgs_common.sh && (echo | ffmpeg -y -loglevel error -r $FPS -i $PNG_PATH/%03d.png -plays 0 $OUTPUT)
