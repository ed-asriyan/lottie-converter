#!/bin/bash

# Check if APIBotToken.txt exists and read the BOT_TOKEN from it
if [ -f "APIBotToken.txt" ]; then
    BOT_TOKEN=$(cat APIBotToken.txt)
else
    # If APIBotToken.txt does not exist, prompt for the BOT_TOKEN
    echo "API token is missing. Please provide your Telegram bot API token."
    echo "Falta el token de la API. Por favor, proporciona tu token de API del bot de Telegram."
    read -p "Enter your Telegram bot API token: " BOT_TOKEN

    # Save the BOT_TOKEN into APIBotToken.txt for future use
    echo "$BOT_TOKEN" > APIBotToken.txt
    echo "API token has been saved in APIBotToken.txt. You won't need to enter it again."
    echo "El token de la API ha sido guardado en APIBotToken.txt. No necesitaras ingresarla nuevamente."
fi

# Prompt for the sticker set name or link
echo "Enter the name of the sticker set (e.g., BadBadDog)."
echo "Ingresa el nombre del paquete de stickers (ejemplo: BadBadDog)."
read -p "Sticker set name or link: " STICKER_SET_NAME

# If a full URL is provided, extract only the sticker set name
if [[ "$STICKER_SET_NAME" == https://t.me/addstickers/* ]]; then
    STICKER_SET_NAME=$(echo "$STICKER_SET_NAME" | sed 's|https://t.me/addstickers/||')
    echo "Extracted sticker set name: $STICKER_SET_NAME"
    echo "Nombre del paquete extraido: $STICKER_SET_NAME"
fi

# Config
DOWNLOAD_DIR_TGS="./TGSs"       # Folder for animated stickers (.tgs)
DOWNLOAD_DIR_CONVERTED="./converted" # Folder for classic stickers (.webp .webm)

mkdir -p "$DOWNLOAD_DIR_TGS"
mkdir -p "$DOWNLOAD_DIR_CONVERTED"

echo "Fetching sticker set information..."
echo "Obteniendo informacion del paquete de stickers..."
STICKER_SET_INFO=$(curl -s -X GET "https://api.telegram.org/bot$BOT_TOKEN/getStickerSet?name=$STICKER_SET_NAME")

if ! echo "$STICKER_SET_INFO" | grep -q '"ok":true'; then
    echo "Error fetching sticker set information. Please check the sticker set name and API token."
    echo "Error al obtener informacion del paquete. Verifica el nombre del paquete y el token de la API."
    exit 1
fi

COUNTER=1

echo "$STICKER_SET_INFO" | jq -c '.result.stickers[]' | while read -r STICKER; do
    # Extract information about the sticker
    FILE_ID=$(echo "$STICKER" | jq -r '.file_id')
    IS_ANIMATED=$(echo "$STICKER" | jq -r '.is_animated')
    IS_VIDEO=$(echo "$STICKER" | jq -r '.is_video')

    echo "Processing sticker #$COUNTER (file_id: $FILE_ID, is_animated: $IS_ANIMATED, is_video: $IS_VIDEO)..."
    echo "Procesando sticker #$COUNTER (file_id: $FILE_ID, es_animado: $IS_ANIMATED, es_video: $IS_VIDEO)..."

    GET_FILE_URL="https://api.telegram.org/bot$BOT_TOKEN/getFile?file_id=$FILE_ID"
    FILE_INFO=$(curl -s -X GET "$GET_FILE_URL")

    if ! echo "$FILE_INFO" | grep -q '"ok":true'; then
        echo "Error fetching file information for file_id: $FILE_ID"
        echo "Error al obtener informacion del archivo para file_id: $FILE_ID"
        COUNTER=$((COUNTER + 1))
        continue
    fi

    FILE_PATH=$(echo "$FILE_INFO" | jq -r '.result.file_path')
    DOWNLOAD_URL="https://api.telegram.org/file/bot$BOT_TOKEN/$FILE_PATH"

    if [ "$IS_ANIMATED" = "true" ]; then
        # Download animated sticker (.tgs)
        OUTPUT_FILE="$DOWNLOAD_DIR_TGS/sticker$COUNTER.tgs"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "Downloaded animated sticker: sticker$COUNTER.tgs"
            echo "Sticker animado descargado: sticker$COUNTER.tgs"
        else
            echo "Error downloading animated sticker: sticker$COUNTER.tgs"
            echo "Error al descargar sticker animado: sticker$COUNTER.tgs"
        fi
    elif [ "$IS_VIDEO" = "true" ]; then
        # Download video sticker (.webm)
        OUTPUT_FILE="$DOWNLOAD_DIR_CONVERTED/sticker$COUNTER.webm"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "Downloaded video sticker: sticker$COUNTER.webm"
            echo "Sticker de video descargado: sticker$COUNTER.webm"
        else
            echo "Error downloading video sticker: sticker$COUNTER.webm"
            echo "Error al descargar sticker de video: sticker$COUNTER.webm"
        fi
    else
        # Download static sticker (.webp)
        OUTPUT_FILE="$DOWNLOAD_DIR_CONVERTED/sticker$COUNTER.webp"
        curl -s -o "$OUTPUT_FILE" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "Downloaded static sticker: sticker$COUNTER.webp"
            echo "Sticker estatico descargado: sticker$COUNTER.webp"
        else
            echo "Error downloading static sticker: sticker$COUNTER.webp"
            echo "Error al descargar sticker estatico: sticker$COUNTER.webp"
        fi
    fi

    COUNTER=$((COUNTER + 1))

    # Add a delay to avoid hitting API rate limits
    sleep 1
done

echo "All stickers have been downloaded."
echo "Todos los stickers han sido descargados."
echo "Animated stickers (.tgs) saved in: $DOWNLOAD_DIR_TGS"
echo "Stickers animados (.tgs) guardados en: $DOWNLOAD_DIR_TGS. Usar converter para convertirlos."
echo "Classic stickers saved in: $DOWNLOAD_DIR_CONVERTED"
echo "Stickers clasicos guardados en: $DOWNLOAD_DIR_CONVERTED"