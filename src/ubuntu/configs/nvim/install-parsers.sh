#!/bin/bash

# Script to install additional Treesitter parsers after initial setup
# Run this after Neovim is installed and build-essential is available

echo "Installing additional Treesitter parsers for Neovim..."
echo "This requires build-essential to be installed."
echo ""

# Install language-specific parsers one at a time
nvim --headless -c "TSInstallSync javascript" -c "qa" 2>/dev/null && echo "✓ JavaScript parser installed"
nvim --headless -c "TSInstallSync typescript" -c "qa" 2>/dev/null && echo "✓ TypeScript parser installed"
nvim --headless -c "TSInstallSync tsx" -c "qa" 2>/dev/null && echo "✓ TSX parser installed"
nvim --headless -c "TSInstallSync html" -c "qa" 2>/dev/null && echo "✓ HTML parser installed"
nvim --headless -c "TSInstallSync css" -c "qa" 2>/dev/null && echo "✓ CSS parser installed"
nvim --headless -c "TSInstallSync java" -c "qa" 2>/dev/null && echo "✓ Java parser installed"
nvim --headless -c "TSInstallSync python" -c "qa" 2>/dev/null && echo "✓ Python parser installed"
nvim --headless -c "TSInstallSync go" -c "qa" 2>/dev/null && echo "✓ Go parser installed"
nvim --headless -c "TSInstallSync rust" -c "qa" 2>/dev/null && echo "✓ Rust parser installed"
nvim --headless -c "TSInstallSync dockerfile" -c "qa" 2>/dev/null && echo "✓ Dockerfile parser installed"
nvim --headless -c "TSInstallSync c" -c "qa" 2>/dev/null && echo "✓ C parser installed"

echo ""
echo "Treesitter parsers installation complete!"
echo "You can manually install additional parsers in Neovim with :TSInstall <language>"