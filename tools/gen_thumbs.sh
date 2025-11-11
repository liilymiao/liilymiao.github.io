#!/usr/bin/env bash
set -euo pipefail

# 依赖：ImageMagick（macOS: brew install imagemagick）
SRC_ROOT="assets/img/albums"
DST_ROOT="assets/thumbs/albums"

# 目标尺寸
TH_W=480        # 缩略图（首页/照片流用）
LG_W=1600       # 大图（灯箱/PhotoSwipe用，足够清晰，流量比原图小很多）

shopt -s globstar nullglob

echo "== Generating thumbnails =="
for f in "$SRC_ROOT"/**/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
  rel="${f#$SRC_ROOT/}"                  # 相对路径 e.g. hkust-hk/img_1234.jpg
  base="${rel%.*}"                       # 不含后缀
  ext="${f##*.}"
  ext_lc="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

  # 输出路径
  out_dir_thumb="$DST_ROOT/$(dirname "$rel")"
  out_dir_large="$DST_ROOT/$(dirname "$rel")"
  mkdir -p "$out_dir_thumb" "$out_dir_large"

  thumb_jpg="$out_dir_thumb/${base##*/}-thumb.jpg"
  large_jpg="$out_dir_large/${base##*/}-large.jpg"

  # 跳过已存在文件（想强制重建可删除再跑）
  if [[ ! -f "$thumb_jpg" ]]; then
    echo "thumb  -> $thumb_jpg"
    magick "$f" -auto-orient -strip -resize "${TH_W}x${TH_W}>" -quality 75 "$thumb_jpg"
  fi

  if [[ ! -f "$large_jpg" ]]; then
    echo "large  -> $large_jpg"
    magick "$f" -auto-orient -strip -resize "${LG_W}x${LG_W}>" -quality 82 "$large_jpg"
  fi

  # （可选）导出 webp；浏览器会优先 webp，流量更省
  # magick "$thumb_jpg" -quality 75 "${thumb_jpg%.jpg}.webp" || true
  # magick "$large_jpg" -quality 82 "${large_jpg%.jpg}.webp" || true
done

echo "== Done =="