#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_plugin() {
    execute "code --install-extension $2" "$1 plugin"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Visual Studio Code\n\n"                                :

# Install VSCode
brew_install "Visual Studio Code" "visual-studio-code" "--cask"

printf "\n"

# Install the VSCode plugins
# install_plugin "AWS Toolkit" "amazonwebservices.aws-toolkit-vscode"
# install_plugin "Amazon Q" "amazonwebservices.amazon-q-vscode"
install_plugin "Better Align" "chouzz.vscode-better-align"
install_plugin "Color Picker" "anseki.vscode-color"
install_plugin "Darkula Official Theme" "dracula-theme.theme-dracula"
# install_plugin "Dev Containers" "ms-vscode-remote.remote-containers"
install_plugin "Docker" "ms-azuretools.vscode-docker"
install_plugin "EditorConfig" "EditorConfig.EditorConfig"
install_plugin "ES7 React Snippets" "dsznajder.es7-react-js-snippets"
install_plugin "File Icons" "vscode-icons-team.vscode-icons"
install_plugin "Fold / Unfold All Icons" "FerrierBenjamin.fold-unfold-all-icone"
install_plugin "GitHub CoPilot" "GitHub.copilot"
install_plugin "GitHub CoPilot Chat" "github.copilot-chat"
install_plugin "Git Ignore" "codezombiech.gitignore"
install_plugin "Go" "golang.go"
# install_plugin "HashiCorp Terraform" "hashicorp.terraform"
install_plugin "JavaScript & TypeScript Nightly" "ms-vscode.vscode-typescript-next"
# install_plugin "Jira & Bitbucket" "atlassian.atlascode"
install_plugin "Kubernetes YAML Formatter" "kennylong.kubernetes-yaml-formatter"
install_plugin "Live Server" "ritwickdey.LiveServer"
install_plugin "Makefile Tools" "ms-vscode.makefile-tools"
install_plugin "MarkdownLint" "DavidAnson.vscode-markdownlint"
# install_plugin "Microsoft Edge Tools" "ms-edgedevtools.vscode-edge-devtools"
install_plugin "Nextjs snippets" "pulkitgangwar.nextjs-snippets"
install_plugin "NGINX Configuration Language Support" "ahmadalli.vscode-nginx-conf"
install_plugin "Peacock" "johnpapa.vscode-peacock"
# install_plugin "PowerShell" "ms-vscode.powershell"
install_plugin "Prettier" "esbenp.prettier-vscode"
# install_plugin "Prisma" "Prisma.prisma"
# install_plugin "Pylance" "ms-python.vscode-pylance"
# install_plugin "Python" "ms-python.python"
# install_plugin "Python Debugger" "ms-python.debugpy"
install_plugin "Reactjs code snippets" "xabikos.reactsnippets"
install_plugin "REST Client" "humao.rest-client"
install_plugin "shell-format" "foxundermoon.shell-format"
# install_plugin "SQLTools" "mtxr.sqltools"
# install_plugin "SQLTools SQLite" "mtxr.sqltools-driver-sqlite"
install_plugin "Tailwind CSS IntelliSense" "bradlc.vscode-tailwindcss"
install_plugin "Tailwind Shades" "bourhaouta.tailwindshades"
# install_plugin "Vim" "vscodevim.vim"
install_plugin "vscode-icons" "vscode-icons-team.vscode-icons"
# install_plugin "WSL" "ms-vscode-remote.remote-wsl"
install_plugin "YAML" "redhat.vscode-yaml"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Close VSCode
osascript -e 'quit app "Visual Studio Code"'
