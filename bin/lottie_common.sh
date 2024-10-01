#!/usr/bin/sh
# this is common source file used by lottie_to_gif.sh, lottie_to_webp.sh
# required bash variables
# $HEIGHT
# $WIDTH
# $FPS
# $OUTPUT_EXTENSION
# $QUALITY

THREADS=0

SCRIPT_DIR=$(dirname "$0")

function print_help() {
  echo "usage: $SCRIPT_DIR/$(basename "$0") [--help] [--output OUTPUT] [--height HEIGHT] [--width WIDTH] [--threads THREADS] [--fps FPS] [--quality QUALITY] path"
  echo
  echo "Lottie animations (.json) and Telegram stickers for Telegram (*.tgs) to animated $OUTPUT_EXTENSION converter"
  echo
  echo "Positional arguments:"
  echo " path              Path to .json or .tgs file to convert"
  echo
  echo "Optional arguments:"
  echo " -h, --help        shows this help message and exits"
  echo " -v, --version     prints version information and exits"
  echo " --output OUTPUT   Output file path"
  echo " --height HEIGHT   Output image height. Default: $HEIGHT"
  echo " --width WIDTH     Output image width. Default: $WIDTH"
  echo " --fps FPS         Output frame rate. Default: $FPS"
  echo " --threads THREADS Number of threads to use. Default: number of CPUs"
  echo " --quality QUALITY Output quality. Default: $QUALITY"
  echo
  echo "It's open-source project: https://github.com/ed-asriyan/lottie-converter"
  echo "Author: Ed Asriyan <contact.lottie-converter@asriyan.me>"
}

function print_version() {
  echo "<local-build>"
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
    -t|--threads)
      THREADS="$2"
      shift
      shift
      ;;
    -h|--help)
      print_help
      exit 1
      ;;
    -v|--version)
      print_version
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

INPUT_PATH=$POSITIONAL_ARG

if [[ -z "$OUTPUT" ]]; then
   OUTPUT=${INPUT_PATH}${OUTPUT_EXTENSION}
fi

TMP_PATH=${OUTPUT}.$RANDOM.tmp
mkdir $TMP_PATH

LOTTIE_PATH=$INPUT_PATH
if [ "${INPUT_PATH: -4}" == ".tgs" ]; then
  LOTTIE_PATH=$TMP_PATH/animation.json
  gunzip -c $INPUT_PATH > $LOTTIE_PATH
fi

$SCRIPT_DIR/lottie_to_png --width $WIDTH --height $HEIGHT --fps $FPS --threads $THREADS --output $TMP_PATH $LOTTIE_PATH

PNG_FILES=$(find $TMP_PATH -type f -name '*.png' | sort -k1)

function cleanup {
  rm -fr $TMP_PATH
}
trap cleanup EXIT
trap cleanup SIGINT
