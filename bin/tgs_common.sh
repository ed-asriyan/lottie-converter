# this is common source file used by tgs_to_gif.sh, tgs_to_webp.sh
# required bash variables
# $HEIGHT
# $WIDTH
# $FPS
# $OUTPUT_EXTENSION
# $QUALITY

SCRIPT_DIR=$(dirname "$0")

function print_help() {
  echo "usage: $SCRIPT_DIR/$(basename "$0") [--help] [--output OUTPUT] [--height HEIGHT] [--width WIDTH] [--fps FPS] path"
  echo
  echo "Animated sticker for Telegram (*.tgs) to animated $OUTPUT_EXTENSION converter"
  echo
  echo "Positional arguments:"
  echo " path              Path to .tgs file to convert"
  echo
  echo "Optional arguments:"
  echo " -h, --help        show this help message and exit"
  echo " --output OUTPUT   Output file path"
  echo " --height HEIGHT   Output image height. Default: $HEIGHT"
  echo " --width WIDTH     Output image width. Default: $WIDTH"
  echo " --fps FPS         Output frame rate. Default: $FPS"
  echo " --quality QUALITY Output quality. Default: $QUALITY"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--height)
      HEIGHT="$2"
      shift
      shift
      ;;
    -w|--width)
      WIDTH="$2"
      shift
      shift
      ;;
    -f|--fps)
      FPS="$2"
      shift
      shift
      ;;
    -q|--quality)
      QUALITY="$2"
      shift
      shift
      ;;
    -o|--output)
      OUTPUT="$2"
      shift
      shift
      ;;
    --help)
      print_help
      exit 1
      ;;
    *)
      POSITIONAL_ARG=$1
      shift
      ;;
  esac
done

if [[ -z "$POSITIONAL_ARG" ]]; then
   print_help
   exit 1
fi

TGS_PATH=$POSITIONAL_ARG

if [[ -z "$OUTPUT" ]]; then
   OUTPUT=${TGS_PATH}${OUTPUT_EXTENSION}
fi

PNG_PATH=${OUTPUT}.tmp
mkdir $PNG_PATH

$SCRIPT_DIR/tgs_to_png --width $WIDTH --height $HEIGHT --fps $FPS --output $PNG_PATH $TGS_PATH

PNG_FILES=$(find $PNG_PATH -type f -name '*.png' | sort -k1)

function cleanup {
  rm -fr $PNG_PATH
}
trap cleanup EXIT
trap cleanup SIGINT
