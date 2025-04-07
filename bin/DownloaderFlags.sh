#!/bin/bash

show_help() {
    echo "Usage: $0 --key <API_KEY> --s <STICKER_SET_NAME>"
    echo "Example: $0 --key '123456789:ABCdefGHI' --s 'BadBadDog'"
    exit 1
}

# JQ?
check_jq() {
    if command -v jq &>/dev/null; then
        JQ_CMD="jq"
        echo "Using system-installed jq"
        return
    fi

    WORK_DIR="$(dirname "$(realpath "$0")")"
    
    # SO?
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if [[ $(uname -m) == "aarch64" || $(uname -m) == "arm64" ]]; then
            JQ_BIN="$WORK_DIR/jq-linux-arm64"
        else
            JQ_BIN="$WORK_DIR/jq-linux-amd64"
        fi
    elif [[ "$OSTYPE" == "linux-android"* ]]; then
        # Termux
        JQ_BIN="$WORK_DIR/jq-linux-arm64"
    elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "win"* ]]; then
        # Windows
        JQ_BIN="$WORK_DIR/jq-windows-amd64.exe"
    else
        echo "Unsupported operating system. Please install jq manually."
        exit 1
    fi

    if [ -f "$JQ_BIN" ]; then
        # jq ejecutable
        chmod +x "$JQ_BIN"
        JQ_CMD="$JQ_BIN"
        echo "Using local jq binary: $JQ_BIN"
    else
        echo "Error: jq is not installed and no local binary found at: $JQ_BIN"
        echo "Please install jq or download the appropriate binary for your system."
        exit 1
    fi
}

# Procesar argumento
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --key) BOT_TOKEN="$2"; shift ;;
        --s) STICKER_SET_NAME="$2"; shift ;;
        *) show_help ;;
    esac
    shift
done

if [ -z "$BOT_TOKEN" ] || [ -z "$STICKER_SET_NAME" ]; then
    echo "Error: Missing required arguments."
    show_help
fi

WORK_DIR="$(dirname "$(realpath "$0")")"
DOWNLOAD_DIR_TGS="$WORK_DIR/TGSs"      
DOWNLOAD_DIR_CONVERTED="$WORK_DIR/converted" 

mkdir -p "$DOWNLOAD_DIR_TGS"
mkdir -p "$DOWNLOAD_DIR_CONVERTED"

# Verificar jq
check_jq

echo "Fetching sticker set information..."
STICKER_SET_INFO=$(curl -s -X GET "https://api.telegram.org/bot$BOT_TOKEN/getStickerSet?name=$STICKER_SET_NAME")

if ! echo "$STICKER_SET_INFO" | $JQ_CMD -e '.ok == true' &>/dev/null; then
    echo "Error fetching sticker set information. Please check the sticker set name and API token."
    exit 1
fi

COUNTER=1
echo "$STICKER_SET_INFO" | $JQ_CMD -c '.result.stickers[]' | while read -r STICKER; do
    FILE_ID=$(echo "$STICKER" | $JQ_CMD -r '.file_id')
    IS_ANIMATED=$(echo "$STICKER" | $JQ_CMD -r '.is_animated')
    IS_VIDEO=$(echo "$STICKER" | $JQ_CMD -r '.is_video')
    
    echo "Processing sticker #$COUNTER (file_id: $FILE_ID, is_animated: $IS_ANIMATED, is_video: $IS_VIDEO)..."
    
    GET_FILE_URL="https://api.telegram.org/bot$BOT_TOKEN/getFile?file_id=$FILE_ID"
    FILE_INFO=$(curl -s -X GET "$GET_FILE_URL")
    
    if ! echo "$FILE_INFO" | $JQ_CMD -e '.ok == true' &>/dev/null; then
        echo "Error fetching file information for file_id: $FILE_ID"
        COUNTER=$((COUNTER + 1))
        continue
    fi
    
    FILE_PATH=$(echo "$FILE_INFO" | $JQ_CMD -r '.result.file_path')
    DOWNLOAD_URL="https://api.telegram.org/file/bot$BOT_TOKEN/$FILE_PATH"
    
    if [ "$IS_ANIMATED" = "true" ]; then
        # Descargar sticker.tgs
        OUTPUT_FILE="$DOWNLOAD_DIR_TGS/sticker$COUNTER.tgs"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"
        if [ $? -eq 0 ]; then
            echo "Downloaded animated sticker: sticker$COUNTER.tgs"
        else
            echo "Error downloading animated sticker: sticker$COUNTER.tgs"
        fi
    elif [ "$IS_VIDEO" = "true" ]; then
        # Descargar sticke.webm
        OUTPUT_FILE="$DOWNLOAD_DIR_CONVERTED/sticker$COUNTER.webm"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"
        if [ $? -eq 0 ]; then
            echo "Downloaded video sticker: sticker$COUNTER.webm"
        else
            echo "Error downloading video sticker: sticker$COUNTER.webm"
        fi
    else
        # Descargar sticker.webp
        OUTPUT_FILE="$DOWNLOAD_DIR_CONVERTED/sticker$COUNTER.webp"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"
        if [ $? -eq 0 ]; then
            echo "Downloaded static sticker: sticker$COUNTER.webp"
        else
            echo "Error downloading static sticker: sticker$COUNTER.webp"
        fi
    fi
    
    COUNTER=$((COUNTER + 1))
    sleep 1
done

echo "All stickers have been downloaded."

# .tgs 2 .webp
echo "Converting animated stickers (.tgs) to .webp..."
shopt -s nullglob
TGS_FILES=("$DOWNLOAD_DIR_TGS"/*.tgs)

if [ ${#TGS_FILES[@]} -eq 0 ]; then
    echo "No .tgs files found in $DOWNLOAD_DIR_TGS. Skipping conversion."
else
    for file in "${TGS_FILES[@]}"; do
        filename=$(basename -- "$file")
        base_name="${filename%.tgs}"
        output_file="$DOWNLOAD_DIR_CONVERTED/${base_name}.webp"
        
        echo "Converting: $filename → ${base_name}.webp"
        # comando
        "$WORK_DIR/lottie_to_webp.sh" "$file" --output "$output_file" --width 200 --height 200 --fps 40 --quality 50
        
        if [ $? -ne 0 ]; then
            echo "Error converting: $filename"
        else
            echo "Converted: ${base_name}.webp"
        fi
    done
fi

echo "Conversion completed. All files saved in: $DOWNLOAD_DIR_CONVERTED"