# check_albums.sh
#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo "🔍 Scanning album/*.md …"
bad=0
for f in album/*.md; do
  first="$(head -n1 "$f" | tr -d '\r')"
  # 找第二个 '---' 的行号
  second_idx="$(awk '/^---[[:space:]]*$/{c++; if(c==2){print NR; exit}}' "$f")"
  t=$(sed -n 's/^title:[[:space:]]*//p' "$f" | head -1)
  te=$(sed -n 's/^title_en:[[:space:]]*//p' "$f" | head -1)
  loc=$(sed -n 's/^location:[[:space:]]*//p' "$f" | head -1)
  cov=$(sed -n 's/^cover:[[:space:]]*//p' "$f" | head -1)

  printf "\n%s\n" "— $f"
  if [[ "$first" != '---' ]]; then
    echo "  ❌ no opening ---"
    bad=$((bad+1))
  fi
  if [[ -z "${second_idx:-}" ]]; then
    echo "  ❌ no closing ---"
    bad=$((bad+1))
  fi
  [[ -n "$t"  ]] || echo "  ⚠️  missing title:"
  [[ -n "$te" ]] || echo "  ⚠️  missing title_en:"
  [[ -n "$loc" ]]|| echo "  ⚠️  missing location:"
  [[ -n "$cov" ]]|| echo "  ⚠️  missing cover:"
done

echo
if (( bad > 0 )); then
  echo "➡️  Found $bad front-matter issues. You can run the auto-fix below."
else
  echo "✅ Front-matter looks structurally OK."
fi
