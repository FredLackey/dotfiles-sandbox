#!/bin/bash

# Script to install Treesitter parsers after initial setup
# Run this after Neovim is installed and build-essential is available

echo "Treesitter Parser Installation Script"
echo "======================================"
echo ""

# Check if build-essential is installed
if ! dpkg -l | grep -q "^ii  build-essential "; then
    echo "⚠ Warning: build-essential is not installed."
    echo "  Some parsers may fail to compile."
    echo "  Install with: sudo apt-get install build-essential"
    echo ""
fi

# Check if Neovim is installed
if ! command -v nvim >/dev/null 2>&1; then
    echo "✗ Error: Neovim is not installed."
    echo "  Please install Neovim first."
    exit 1
fi

echo "Installing Treesitter parsers..."
echo ""

# Function to install a parser
install_parser() {
    local parser=$1
    local display_name=$2
    
    echo -n "Installing $display_name parser... "
    if nvim --headless -c "TSInstallSync $parser" -c "qa" 2>/dev/null; then
        echo "✓"
        return 0
    else
        echo "✗ (failed)"
        return 1
    fi
}

# Install basic parsers first (these usually work)
echo "Basic parsers:"
install_parser "lua" "Lua"
install_parser "vim" "Vim"
install_parser "vimdoc" "Vim documentation"
install_parser "bash" "Bash"
install_parser "json" "JSON"
install_parser "yaml" "YAML"
install_parser "markdown" "Markdown"

echo ""
echo "Web development parsers:"
install_parser "html" "HTML"
install_parser "css" "CSS"
install_parser "javascript" "JavaScript"
install_parser "typescript" "TypeScript"
install_parser "tsx" "TSX/JSX"

echo ""
echo "Programming language parsers:"
install_parser "python" "Python"
install_parser "java" "Java"
install_parser "c" "C"
install_parser "cpp" "C++"
install_parser "go" "Go"
install_parser "rust" "Rust"

echo ""
echo "Other parsers:"
install_parser "dockerfile" "Dockerfile"
install_parser "sql" "SQL"
install_parser "toml" "TOML"

echo ""
echo "Installation complete!"
echo ""
echo "Tip: You can install parsers manually in Neovim:"
echo "  :TSInstall <language>     - Install a specific parser"
echo "  :TSInstallBasic           - Install basic parsers"
echo "  :TSInstallWeb             - Install web development parsers"
echo "  :TSInstallAll             - Install all common parsers"
echo "  :TSInstallInfo            - Show installed parsers"