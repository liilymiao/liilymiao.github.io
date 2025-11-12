#!/bin/bash
# ============================================================
# check_color_leaks.sh
# 检测 repo 中 CSS 文件是否仍包含硬编码颜色值（非变量）
# 主要检查:
#   - background / color / border / shadow 等属性中使用 #RGB 或 rgb()
#   - 未使用 var(--xxx) 的固定值
# ============================================================

echo "🔍 Scanning for hardcoded colors in CSS files..."
echo "------------------------------------------------"

# 搜索路径可按需修改（默认检测 assets 和 stylesheets 文件夹）
TARGET_DIRS=("assets" "stylesheets")

for DIR in "${TARGET_DIRS[@]}"; do
  if [ -d "$DIR" ]; then
    echo "📂 Checking $DIR ..."
    grep -HnE 'color:|background:|border:|shadow:' "$DIR"/*.css 2>/dev/null \
      | grep -E '#[0-9A-Fa-f]{3,6}|rgb\(|rgba\(' \
      | grep -vE 'var\(--' \
      | sed "s|^|[$DIR] |"
  fi
done

echo "------------------------------------------------"
echo "✅ 如果没有输出，则所有颜色都已变量化。"
echo "⚠️ 否则，请检查上方列出的行（替换为 var(--xxx)）"
