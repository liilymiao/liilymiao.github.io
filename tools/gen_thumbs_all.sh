#!/bin/bash
set -e

SRC="assets/img/albums"
OUT="assets/thumbs/albums"

echo "== Regenerating ALL thumbnails =="
echo "Source: $SRC"
echo "Output: $OUT"
echo ""

mkdir -p "$OUT"

# 遍历每个相册文件夹
for album in "$SRC"/*; do
    [ -d "$album" ] || continue

    album_name=$(basename "$album")
    out_dir="$OUT/$album_name"

    mkdir -p "$out_dir"

    echo "-- Album: $album_name --"

    # 遍历此相册内所有 jpg 文件
    for img in "$album"/*.jpg "$album"/*.JPG "$album"/*.jpeg "$album"/*.JPEG; do
        [ -f "$img" ] || continue

        fname=$(basename "$img")
        base="${fname%.*}"
        base_lower=$(echo "$base" | tr 'A-Z' 'a-z')

        thumb="$out_dir/${base_lower}-thumb.jpg"
        large="$out_dir/${base_lower}-large.jpg"

        echo "thumb -> $thumb"
        convert "$img" -resize 480x480^ -gravity center -extent 480x480 "$thumb"

        echo "large -> $large"
        convert "$img" -resize 1600x1600 "$large"
    done

    echo ""
done

echo "== ALL thumbnails regenerated successfully =="
