#!/usr/bin/env bash
# Install git hooks for the repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "Installing git hooks..."

# Install pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/usr/bin/env bash
# Pre-commit hook to prevent files larger than 10MB from being committed

# Maximum file size in bytes (10MB = 10 * 1024 * 1024)
MAX_SIZE=10485760

# Check for large files in the index
large_files=$(git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        if [ "$size" -gt "$MAX_SIZE" ]; then
            echo "$file ($size bytes)"
        fi
    fi
done)

if [ -n "$large_files" ]; then
    echo "Error: The following files are larger than 10MB and cannot be committed:"
    echo "$large_files"
    echo ""
    echo "Please either:"
    echo "1. Remove these files from the commit: git reset HEAD <file>"
    echo "2. Add them to .gitignore if they shouldn't be tracked"
    echo "3. Use Git LFS for large files: git lfs track '<file>'"
    echo ""
    exit 1
fi

# Run standard formatting checks if they exist
if [ -f "flake.nix" ]; then
    echo "Running nix flake check..."
    if ! nix flake check 2>/dev/null; then
        echo "Warning: nix flake check failed, but continuing with commit"
    fi
fi

exit 0
EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Pre-commit hook installed successfully"
echo "📏 Files larger than 10MB will be blocked from commits"
echo "🔧 Hook also runs 'nix flake check' for formatting validation"