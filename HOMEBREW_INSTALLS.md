# Homebrew Installs - Legacy Project

This document lists all Homebrew packages and applications installed by the legacy dotfiles project, organized by category.

## Shell & Terminal Tools

### Bash
- **bash** - Latest version of Bash shell
- **bash-completion@2** - Bash completion functionality

### tmux
- **tmux** - Terminal multiplexer
- **reattach-to-user-namespace** (Pasteboard) - macOS pasteboard access for tmux

## Development Tools

### Version Control
- **git** - Git version control system

### Text Editors
- **vim** - Vim text editor
- **sublime-text** - Sublime Text editor

### IDE & Code Editors
- **visual-studio-code** (--cask) - Visual Studio Code IDE
- **cursor** (--cask) - AI-powered code editor

### Programming Languages
- **go** - Go programming language

### Command Line Utilities
- **shellcheck** - Shell script analysis tool
- **awscli** - AWS Command Line Interface
- **lftp** - Advanced FTP client
- **yarn** - JavaScript package manager (conditional on NVM)

### Infrastructure & DevOps
- **docker** (--cask) - Docker containerization platform
- **tfenv** - Terraform version manager
- **tailscale** - VPN and secure networking

## Media & Image Tools

### Image Processing
- **imageoptim** (--cask) - Image optimization tool
- **pngyu** (--cask) - PNG compression tool

### Video Tools
- **atomicparsley** - Metadata manipulation for video files
- **ffmpeg** - Video processing and conversion
- **vlc** (--cask) - VLC media player
- **elmedia-player** (--cask) - Media player

### Audio/Music
- **spotify** (--cask) - Spotify music streaming
- **tidal** (--cask) - Tidal music streaming

## Data & Utilities

### Data Processing
- **jq** - JSON processor
- **yq** - YAML processor

### Security & Privacy
- **gpg** - GNU Privacy Guard
- **pinentry-mac** - GPG PIN entry for macOS
- **nordpass** (--cask) - Password manager

## Web Browsers

### Chrome
- **google-chrome** (--cask) - Google Chrome browser
- **google-chrome@canary** (--cask) - Chrome Canary (development version)

### Safari
- **safari-technology-preview** (--cask) - Safari Technology Preview (requires macOS 10.11.4+)

## Communication & Collaboration

### Messaging
- **messenger** (--cask) - Facebook Messenger
- **whatsapp** (--cask) - WhatsApp desktop
- **skype** (--cask) - Skype video calling
- **slack** (--cask) - Slack team communication

### Microsoft Office
- **microsoft-office** (--cask) - Microsoft Office 365
- **microsoft-teams** (--cask) - Microsoft Teams

## Productivity Applications

### Screen Recording & Capture
- **snagit** (--cask) - Screen capture and recording
- **camtasia** (--cask) - Screen recording and video editing

### System Utilities
- **appcleaner** (--cask) - Application uninstaller
- **caffeine** (--cask) - Prevents system sleep
- **keyboard-maestro** (--cask) - Automation and macro tool

### Database Tools
- **dbschema** (--cask) - Database design and management
- **mysqlworkbench** (--cask) - MySQL Workbench
- **studio-3t** (--cask) - MongoDB GUI

### Creative Tools
- **adobe-creative-cloud** (--cask) - Adobe Creative Suite
- **drawio** (--cask) - Diagramming and flowchart tool

### Development & Testing
- **postman** - API development and testing
- **beyond-compare** (--cask) - File and folder comparison

### 3D Printing & Hardware
- **bambu-studio** (--cask) - 3D printing software
- **balenaetcher** (--cask) - USB/SD card imaging tool

### AI & Productivity
- **chatgpt** (--cask) - ChatGPT desktop application
- **superwhisper** (--cask) - AI transcription tool

### Remote Access & Terminal
- **termius** (--cask) - SSH client and terminal

### Video Communication
- **zoom** (--cask) - Video conferencing

### Streaming & Content
- **yt-dlp** - YouTube and video downloader

## Web Font Tools

### Font Conversion (Custom Tap: bramstein/webfonttools)
- **sfnt2woff-zopfli** - TTF/OTF to WOFF conversion with Zopfli compression
- **sfnt2woff** - TTF/OTF to WOFF conversion
- **woff2** - WOFF2 font format tools

## Commented Out / Disabled Packages

The following packages are present in the code but commented out:

### Compression Tools
- brotli
- zopfli

### Browsers (Disabled)
- firefox (--cask)
- firefox@developer-edition (--cask)
- firefox-nightly (--cask)
- chromium (--cask)

### Development Tools (Disabled)
- github/gh/gh (GitHub CLI)
- terraform
- python
- mysql
- aws-sam-cli
- doctl (DigitalOcean CLI)
- twilio/brew/twilio

### Applications (Disabled)
- android-file-transfer (--cask)
- eye-d3
- rectangle (--cask)
- the-unarchiver (--cask)
- gimp (--cask)
- imagemagick
- cloudmounter (--cask)
- datagrip (--cask)
- divvy (--cask)
- dropbox (--cask)
- elgato-stream-deck (--cask)
- evernote (--cask)
- loopback (--cask)
- ngrok (--cask)
- nordvpn (--cask)
- qfinder-pro (--cask)
- shottr (--cask)
- signal (--cask)
- sitesucker-pro (--cask)
- thunderbird (--cask)
- vmware-fusion (--cask)
- wireshark (--cask)

## Total Count

- **Active Installs**: 65 packages
- **Commented/Disabled**: 29 packages
- **Total Packages Referenced**: 94 packages

## Installation Script Locations

The install scripts are organized in:
- `legacy/src/os/installs/macos/` - macOS-specific installations
- Main installer: `legacy/src/os/installs/macos/main.sh`

## Notes

1. All installations use the `brew_install` utility function defined in `utils.sh`
2. Cask applications are marked with `--cask` flag
3. Some packages use custom taps (e.g., bramstein/webfonttools)
4. Installation order is managed by the main installation script
5. Some installs are conditional (e.g., Yarn only installs if NVM is present)
6. App Store applications are opened via direct macappstores:// URLs rather than installed via Homebrew