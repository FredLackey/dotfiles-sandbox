#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous\n\n"

# install_package "VLC" "vlc"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# execute \
#   "sudo apt remove docker docker-engine docker.io" \
#   "Docker (remove older)"

install_package "Debian Archive Keyring" "debian-archive-keyring"
install_package "CA Certificates" "ca-certificates"
install_package "Curl" "curl"
install_package "Software Properties (Common)" "software-properties-common"
install_package "GNU Privacy Guard" "gnupg"

execute \
  "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -" \
  "Docker (add keys)"

execute \
  "sudo apt-key fingerprint 0EBFCD88" \
  "Docker (add fingerprint)"

execute \
  "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"" \
  "Docker (add repository)"

execute \
  "sudo apt update" \
  "Docker (update)"

install_package "Docker CE" "docker-ce"

execute \
  "sudo usermod -aG docker $USER" \
  "Docker (update group)"

install_package "Docker Compose" "docker-compose"
