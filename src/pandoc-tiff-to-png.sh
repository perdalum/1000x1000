#!/bin/bash
# Script to convert TIFF images extracted by pandoc to PNG format
# and update README.md to reference the PNG files instead of TIFF
# Uses sips command (macOS native) for image conversion

set -e

README_FILE="${1:-README.md}"
IMAGE_DIR="${2:-.}"

# Check if README file exists
if [ ! -f "$README_FILE" ]; then
    echo "Error: README file '$README_FILE' not found"
    exit 1
fi

# Find all TIFF files in the image directory
TIFF_FILES=$(find "$IMAGE_DIR" -maxdepth 1 -type f \( -name "*.tiff" -o -name "*.tif" \) 2>/dev/null)

if [ -z "$TIFF_FILES" ]; then
    echo "No TIFF files found in $IMAGE_DIR"
    exit 0
fi

echo "Converting TIFF images to PNG..."

# Convert each TIFF file to PNG using sips
for tiff_file in $TIFF_FILES; do
    # Get the base name without extension
    base_name=$(basename "$tiff_file" | sed 's/\.[tT][iI][fF][fF]*$//')
    png_file="$IMAGE_DIR/${base_name}.png"

    # Convert TIFF to PNG using sips (macOS built-in command)
    if command -v sips &> /dev/null; then
        sips -s format png "$tiff_file" --out "$png_file" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "  Converted: $(basename "$tiff_file") → $(basename "$png_file")"
            rm "$tiff_file"
        else
            echo "Error: Failed to convert $tiff_file"
            exit 1
        fi
    else
        echo "Error: sips command not found. This script requires macOS."
        exit 1
    fi
done

echo "Updating README.md with PNG references..."

# Replace TIFF references with PNG references ONLY within markdown image links: ![...](...)
sed -E -i '' 's/!\[([^]]*)\]\(([^)]*)\.tiff\)/![\1](\2.png)/g' "$README_FILE"

echo "Image conversion and README update complete!"