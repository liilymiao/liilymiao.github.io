#!/usr/bin/env bash
set -euo pipefail

ROOT="assets/img/albums"
OUT="assets/thumbs/albums"

mkdir -p "$OUT"

for dir in "$ROOT"/*; do
  [ -d "$dir" ] || continue
  alb="$(basename "$dir")"
  echo "== Album: $alb =="

  mkdir -p "$OUT/$alb"

  # *.jpg / *.JPG / *.jpeg / *.JPEG 都处理
  for img in "$dir"/*.jp*g; do
    [ -f "$img" ] || continue

    base="$(basename "$img")"
    name="${base%.*}"
    lower="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"

    # 为了彻底兼容大小写问题：同时输出「原大小写名」和「全小写名」
    for variant in "$name" "$lower"; do
      th="$OUT/$alb/${variant}-thumb.jpg"
      lg="$OUT/$alb/${variant}-large.jpg"

      # thumb：裁成 3:2（480×320）
      convert "$img" -auto-orient -resize "480x480^" -gravity center -extent 480x320 "$th"

      # large：最长边 1600，保持比例
      convert "$img" -auto-orient -resize "1600x1600>" "$lg"

      echo "thumb  -> $th"
      echo "large  -> $lg"
    done
  done
done

echo "== All done =="
