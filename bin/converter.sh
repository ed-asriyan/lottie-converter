#!/bin/bash

# Agregar .tgs a /TGSs y Ejecutar el Script. ########################################
WORK_DIR="$(dirname "$(realpath "$0")")"
TGS_DIR="$WORK_DIR/TGSs"  # Carpeta de archivos .tgs
OUTPUT_DIR="$WORK_DIR/converted"

mkdir -p "$OUTPUT_DIR"


# Ajustes Graficos ###############################################################
HEIGHT=200  # 
WIDTH=200   # 
FPS=40      #  fluidez 
QUALITY=50  # Calidad 

shopt -s nullglob
TGS_FILES=("$TGS_DIR"/*.tgs)
if [ ${#TGS_FILES[@]} -eq 0 ]; then
    echo "No hay archivos .tgs en la carpeta $TGS_DIR"
    exit 1
fi

for file in "${TGS_FILES[@]}"; do
    filename=$(basename -- "$file")
    base_name="${filename%.tgs}"  
    output_file="$OUTPUT_DIR/${base_name}.webp"
    
    echo "Convirtiendo: $filename → ${base_name}.webp"
    
    # Comando
    "$WORK_DIR/lottie_to_webp.sh" "$file" --output "$output_file" --width $WIDTH --height $HEIGHT --fps $FPS --quality $QUALITY
    
    if [ $? -ne 0 ]; then
        echo "Error al convertir: $filename"
    else
        echo "Convertido ${base_name}.webp"
    fi
done

echo "Completado. Archivos guardados en: $OUTPUT_DIR"