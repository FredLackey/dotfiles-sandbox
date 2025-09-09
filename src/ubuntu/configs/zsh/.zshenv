# ~/.zshenv - Environment variables for all ZSH shells
# This file is sourced for all shells (login, interactive, and scripts)

# Set default editor
export EDITOR='vim'

# Set language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Add user's private bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add user's bin to PATH if it exists
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi