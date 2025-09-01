# macOS Installation Tools and Utilities

This document provides a comprehensive list of all utilities and tools that are installed when deploying the dotfiles configuration for macOS systems.

## Installation Order

The macOS installation follows this sequence (as defined in `src/os/installs/macos/main.sh`):

1. **Xcode** - Development environment setup
2. **Homebrew** - Package manager
3. **Bash** - Updated shell environment
4. **Git** - Version control
5. **Node Version Manager (NVM)** - Node.js management
6. **Browsers** - Web browsers
7. **Compression Tools** - Archive utilities
8. **GPG** - Encryption tools
9. **Image Tools** - Image processing utilities
10. **Miscellaneous** - General utilities
11. **Miscellaneous Tools** - Additional applications
12. **NPM** - Node package manager updates
13. **tmux** - Terminal multiplexer
14. **Video Tools** - Video processing utilities
15. **Vim** - Text editor
16. **Visual Studio Code** - Code editor with extensions
17. **Web Font Tools** - Font conversion utilities

## Core Development Environment

### Xcode
- **Xcode.app** - Apple's integrated development environment
- **Xcode Command Line Tools** - Essential development tools
- Automatic license agreement acceptance

### Homebrew
- **Homebrew** - macOS package manager
- Analytics opt-out configuration
- Automatic updates and upgrades

### Shell Environment
- **Bash** (latest version via Homebrew)
- **Bash Completion 2** - Enhanced command completion
- Default shell configuration update

## Version Control & Development Tools

### Git
- **Git** - Distributed version control system

### Node.js Environment
- **NVM (Node Version Manager)** - Node.js version management
- **Node.js 20** - Latest stable Node.js version
- **NPM** - Node package manager (updated to latest)

## Browsers

### Google Chrome
- **Google Chrome** - Primary web browser
- **Google Chrome Canary** - Development browser

### Safari
- **Safari Technology Preview** - Latest Safari features (macOS 10.11.4+)

## Security & Encryption

### GPG Tools
- **GPG** - GNU Privacy Guard
- **Pinentry Mac** - Secure password entry

## Media & Content Tools

### Image Processing
- **ImageOptim** - Image optimization tool
- **Pngyu** - PNG compression utility

### Video Processing
- **AtomicParsley** - Metadata manipulation for video files
- **FFmpeg** - Comprehensive video processing toolkit

### Media Players
- **VLC** - Versatile media player

## Terminal & System Tools

### Terminal Enhancement
- **tmux** - Terminal multiplexer
- **reattach-to-user-namespace** - Pasteboard support for tmux

### Text Processing
- **jq** - JSON processor
- **yq** - YAML processor

### Development Utilities
- **ShellCheck** - Shell script analysis tool
- **Yarn** - Alternative Node.js package manager (if NVM is installed)

## Text Editors & IDEs

### Vim
- **Vim** - Enhanced text editor
- **Minpac** - Vim plugin manager
- Custom plugin configuration

### Visual Studio Code
- **Visual Studio Code** - Primary code editor

#### VSCode Extensions
**Development Tools:**
- Better Align
- Color Picker
- Docker
- EditorConfig
- GitHub Copilot
- GitHub Copilot Chat
- Git Ignore
- Live Server
- Makefile Tools
- REST Client

**Language Support:**
- ES7 React Snippets
- Go
- JavaScript & TypeScript Nightly
- Nextjs snippets
- Reactjs code snippets
- shell-format
- YAML

**Frameworks & Libraries:**
- Tailwind CSS IntelliSense
- Tailwind Shades

**Utilities:**
- Darkula Official Theme
- File Icons (vscode-icons)
- Fold / Unfold All Icons
- MarkdownLint
- NGINX Configuration Language Support
- Peacock
- Prettier

## Professional Applications

### Creative & Design
- **Adobe Creative Cloud** - Creative suite
- **Camtasia** - Screen recording and video editing
- **Snagit** - Screen capture tool

### Database Tools
- **DbSchema** - Database design tool
- **MySQL Workbench** - MySQL administration
- **Studio 3T** - MongoDB client

### Communication
- **ChatGPT** - AI assistant
- **Messenger** - Facebook Messenger
- **Microsoft Teams** - Team collaboration
- **Skype** - Video calling
- **Slack** - Team communication
- **WhatsApp** - Messaging

### Productivity
- **Microsoft Office 365** - Office suite
- **Keyboard Maestro** - Automation tool
- **Caffeine** - Prevent system sleep

### Development & DevOps
- **AWS CLI** - Amazon Web Services command line
- **Cursor** - AI-powered code editor
- **Docker** - Containerization platform
- **Draw.IO** - Diagramming tool
- **Go** - Programming language
- **Postman** - API development tool
- **Sublime Text** - Text editor
- **Terraform (tfenv)** - Infrastructure as code (version manager)

### System Utilities
- **AppCleaner** - Application uninstaller
- **Beyond Compare** - File comparison tool
- **Tailscale** - VPN and networking

### Specialized Tools
- **Bambu Studio** - 3D printing software
- **Balena Etcher** - OS image flasher
- **Elmedia Player** - Media player
- **LFTP** - File transfer client
- **Nord Pass** - Password manager
- **Superwhisper** - Voice transcription
- **Termius** - SSH client
- **yt-dlp** - Video downloader

### Entertainment
- **Spotify** - Music streaming
- **Tidal** - High-quality music streaming
- **Zoom** - Video conferencing

## Web Font Tools

### Font Conversion Utilities
- **sfnt2woff-zopfli** - TTF/OTF to WOFF conversion (Zopfli compression)
- **sfnt2woff** - TTF/OTF to WOFF conversion
- **woff2** - WOFF2 font format support

*Installed via bramstein/webfonttools tap*

## Mac App Store Applications

The following applications are opened in the Mac App Store for manual installation:

- **Xcode** (if not already installed)
- **LanScan** - Network scanner
- **Magnet** - Window management

## Installation Notes

- All Homebrew packages are installed with automatic dependency resolution
- Cask applications (GUI apps) are installed via `--cask` flag
- Some tools require specific taps (third-party repositories)
- Installation scripts include error handling and status reporting
- Analytics are disabled for Homebrew by default
- The system is configured to use the latest Bash version as the default shell

## Commented/Optional Tools

The following tools are available but commented out in the installation scripts:

- Brotli, Zopfli (compression)
- GitHub CLI
- Firefox browsers
- Python, MySQL
- Various development tools (ngrok, SAM CLI, Terraform direct install)
- Additional creative and productivity applications

These can be enabled by uncommenting the relevant lines in the installation scripts.
