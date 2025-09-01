#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous Tools\n\n"

brew_install "ShellCheck" "shellcheck"

if [ -d "$HOME/.nvm" ]; then
    brew_install "Yarn" "yarn"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

brew_install "Adobe Creative Cloud" "adobe-creative-cloud" "--cask"
brew_install "AppCleaner" "appcleaner" "--cask"
brew_install "AWS CLI" "awscli"

brew_install "Bambu Studio" "bambu-studio" "--cask"
brew_install "Baslena Etcher" "balenaetcher" "--cask"
brew_install "Beyond Compare" "beyond-compare" "--cask"

brew_install "Caffeine" "caffeine" "--cask"
brew_install "Camtasia" "camtasia" "--cask"
brew_install "ChatGPT" "chatgpt" "--cask"
# brew_install "Cloud Mounter" "cloudmounter" "--cask"
brew_install "Cursor" "cursor" "--cask"

# brew_install "DataGrip" "datagrip" "--cask"
brew_install "DbSchema" "dbschema" "--cask"
# brew_install "DitialOcean Client API Tool" "doctl"
# brew_install "Divvy" "divvy" "--cask"
brew_install "Docker" "docker" "--cask"
brew_install "Draw.IO" "drawio" "--cask"
# brew_install "Dropbox" "dropbox" "--cask"

brew_install "Elmedia Player" "elmedia-player" "--cask"
# brew_install "Elgato Stream Deck" "elgato-stream-deck" "--cask"
# brew_install "Evernote" "evernote" "--cask"

brew_install "Go" "go"

brew_install "Keyboard Maestro" "keyboard-maestro" "--cask"

brew_install "LFTP" "lftp"
# brew_install "Loopback" "loopback" "--cask"

brew_install "Messenger" "messenger" "--cask"
brew_install "Microsoft Office 365" "microsoft-office" "--cask"
brew_install "Microsoft Teams" "microsoft-teams" "--cask"
# brew_install "MySQL" "mysql"
brew_install "MySQL Workbench" "mysqlworkbench" "--cask"

# brew_install "ngrok" "ngrok" "--cask"
brew_install "Nord Pass" "nordpass" "--cask"
# brew_install "Nord VPN" "nordvpn" "--cask"

brew_install "Postman" "postman"
# brew_install "Python" "python"

# brew_install "QFinder Pro" "qfinder-pro" "--cask"

# brew_install "SAM CLI" "aws-sam-cli"
# brew_install "Shottr" "shottr" "--cask"
# brew_install "Signal" "signal" "--cask"
# brew_install "SiteSucker" "sitesucker-pro" "--cask"
brew_install "Skype" "skype" "--cask"
brew_install "Slack" "slack" "--cask"
brew_install "Snagit" "snagit" "--cask"
brew_install "Spotify" "spotify" "--cask"
brew_install "Studio 3T" "studio-3t" "--cask"
brew_install "Sublime Text" "sublime-text"
brew_install "Superwhisper" "superwhisper" "--cask"

brew_install "Tailscale" "tailscale"
brew_install "Termius" "termius" "--cask"
# brew_install "Terraform" "terraform"
brew_install "Terraform (tfenv)" "tfenv"
brew_install "Tidal" "tidal" "--cask"
# brew_install "Thunderbird" "thunderbird" "--cask"
# brew_install "Twilio" "twilio/brew/twilio"

# execute \
#     "twilio autocomplete bash" \
#     "Twilio Autocomplete"

#WhatsApp
# open "macappstores://itunes.apple.com/en/app/xcode/id1147396723"
open "macappstores://itunes.apple.com/en/app/xcode/id310633997"

#LanScan
open "macappstores://itunes.apple.com/en/app/lanscan/id472226235"

#Magnet
open "macappstores://itunes.apple.com/en/app/lanscan/id441258766"

brew_install "Visual Studio Code" "visual-studio-code" "--cask"
# brew_install "VMWare Fusion" "vmware-fusion" "--cask"

brew_install "WhatsApp" "whatsapp" "--cask"
# brew_install "Wireshark" "wireshark" "--cask"

brew_install "yt-dlp" "yt-dlp"

brew_install "Zoom" "zoom" "--cask"


# if [ ! -d "ls -l /usr/local/bin/python" ]; then
#   execute \
#       "sudo ln -s -f /opt/homebrew/bin/python3 /usr/local/bin/python" \
#       "Set Python3 to default"
# fi


