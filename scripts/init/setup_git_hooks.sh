#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
HOOKS_DIR="$ROOT_DIR/.git/hooks"
CUSTOM_HOOK="$HOOKS_DIR/pre-commit"

# Создаём .git/hooks если его нет
mkdir -p "$HOOKS_DIR"

cat > "$CUSTOM_HOOK" <<'EOF'
#!/usr/bin/env bash
# --- pre-commit hook to ensure all .sh files in scripts/ are executable ---

set -euo pipefail
echo "🔍 Checking executable permissions for scripts..."

NON_EXEC=$(find scripts -type f -name "*.sh" ! -perm -111 || true)

if [ -n "$NON_EXEC" ]; then
  echo "⚠️  Some scripts are not executable. Fixing..."
  echo "$NON_EXEC" | while read -r file; do
    chmod +x "$file"
    git update-index --chmod=+x "$file"
    echo "  ✅ Fixed: \$file"
  done
else
  echo "✅ All scripts are executable"
fi
EOF

chmod +x "$CUSTOM_HOOK"
echo "✅ Git pre-commit hook установлен в $CUSTOM_HOOK"
