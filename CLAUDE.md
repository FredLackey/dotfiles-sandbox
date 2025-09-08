# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles configuration repository that automates the setup of development environments for **full-stack Node.js and Java developers**. The repository is designed for **development only** - scripts are written here and deployed to target systems separately.

**Target User**: Software engineers specializing in full-stack development who need:
- Modern JavaScript/TypeScript development with Node.js
- Enterprise Java development with Spring Boot and microservices
- API development and testing tools
- Container-based development workflows
- Database management and query tools
- Mastery of text-based IDEs for productive coding in any environment (local, SSH, containers)
- Optional GUI tools for convenience when available

### Target Environments

Currently targeting three environments:
1. **Windows WSL running Ubuntu** - Windows Subsystem for Linux with Ubuntu distribution
   - Vim/Neovim configured as primary IDE
   - Full Node.js and Java toolchain
   - Seamless Windows filesystem integration
2. **Ubuntu Server 22.04 LTS** - Standalone Ubuntu server installations
   - SSH-friendly development setup
   - Vim/Neovim as primary IDE with tmux for session management
   - Complete build and deployment tools
3. **macOS 15 (Sequoia)** - Current macOS desktop systems
   - Vim/Neovim as primary IDE
   - Supplementary GUI tools (VS Code, optional IntelliJ) for convenience
   - Homebrew-based package management
   - Docker Desktop for containerized development

Future platforms (to be added after initial three are complete):
- **RHEL (Red Hat Enterprise Linux)** - Enterprise Linux distributions
- **AWS Linux** - Amazon's Linux distribution for EC2 instances

Each environment has its own specific requirements, shell versions, and system utilities that must be accounted for in platform-specific implementations.

### Shell Philosophy
- **Interactive Shell**: ZShell (zsh) is the preferred target environment, using the version that ships with the system
- **Scripting Language**: Bash for all automation and setup scripts
- **Shell Management**: Never install or upgrade shell interpreters - work with what's already available on target systems

## Critical Development Rules

### DO NOT MODIFY THIS DEVELOPMENT SYSTEM
- **NO package installations** (brew, apt, npm, etc.)
- **NO system modifications** (preferences, configurations, settings)
- **NO file system changes** outside this repository
- **NO downloads** of external tools or binaries
- **NO execution** of installation or configuration commands

All scripts are developed here and executed on different target systems.

### Write for Junior Developers
- **Every script and document must be written so a junior developer can understand it**
- **Use clear, descriptive variable names** (avoid cryptic abbreviations)
- **Add explanatory comments** for non-obvious logic or system commands
- **Break complex operations** into smaller, understandable steps
- **Document the "why"** not just the "what" for design decisions
- **Avoid clever one-liners** in favor of readable, maintainable code
- **Provide examples** where concepts might be unclear

### Text File Creation Rules
- **NEVER use control characters** (ASCII 0x00-0x1F except 0x09 tab, 0x0A newline, 0x0D carriage return)
- **ABSOLUTELY NO NUL characters** (0x00) - these appear as red "NUL" markers in IDEs
- **NO invisible characters** like ENQ (0x05), NUL (0x00), STX (0x02), DC4 (0x14), FS (0x1C), or other non-printable ASCII codes
- **Use only standard UTF-8 text** for all markdown, configuration, and documentation files
- **Control characters can cause**: IDE warnings (red squares/markers), parsing errors, and display issues
- **If control characters are detected**, remove them immediately with: `perl -pi -e 's/[\x00-\x08\x0B-\x0C\x0E-\x1F]//g' filename`
- **Common problematic characters**: NUL (0x00), STX (0x02), ENQ (0x05), DC4 (0x14), FS (0x1C)
- **Directory Trees and ASCII Art**:
  - **USE ONLY standard box-drawing characters**: ├── │ └── ─
  - **NEVER copy/paste ASCII art** from external sources (often contains hidden control characters)
  - **BUILD directory trees character by character** using only the approved box-drawing characters
  - **AVOID special Unicode box-drawing** beyond the basic set listed above
  - **TEST with**: `perl -ne 'print "$.: $_" if /[\x00-\x08\x0B-\x0C\x0E-\x1F]/' filename` to verify no control characters

### Fully Automated Execution
- **Scripts must run without any human intervention**
- **NO prompts for user input** during execution
- **NO "press any key to continue"** or confirmation dialogs
- **NO interactive menus** or option selection
- **All decisions must be predetermined** in the script logic
- **Purpose: Complete machine setup from start to finish automatically**
- **If configuration options are needed**, use environment variables or config files, never prompts

### Critical Design Requirement: Idempotency

**ALL scripts and logic MUST be idempotent** - this is non-negotiable. Scripts must be capable of being executed multiple times without causing problems, duplications, or inconsistencies.

#### Idempotency Requirements:
- **Check before modifying** - verify if a change is needed before making it
- **Never blindly append** to files without checking for existing content
- **Test for existence** before creating files, directories, or settings
- **Use conditional logic** to determine if action is needed
- **Validate current state** before making any changes
- **Ensure multiple executions** produce the same result every time

## Architecture and Structure

### Directory Organization

```
src/
├── common/    # Cross-platform configurations
│              # - Shell configs (bash, zsh)
│              # - Developer aliases and functions
│              # - Git workflow optimizations
│              # - Universal productivity tools
├── macos/     # macOS-specific implementations
│              # - Homebrew package management
│              # - Vim/Neovim IDE configuration
│              # - Supplementary GUI tools (VS Code)
│              # - Node.js, Java, build tools
│              # - Docker Desktop
│              # - Database clients
└── ubuntu/    # Ubuntu-specific implementations
               # - APT package management
               # - Vim/Neovim as primary IDE
               # - Node.js (NodeSource), OpenJDK
               # - Docker CE
               # - Terminal multiplexing (tmux)

scripts/       # Repository maintenance utilities (git operations, documentation)
               # Note: Repository scripts do NOT perform system configuration

_legacy/       # Reference: Current production dotfiles (trusted but outdated practices)
_archive/      # Reference: Previous auto-generated attempt (DO NOT TRUST OR COPY)
_examples/     # Reference: Other developers' dotfiles (trusted reference for learning)
```

### ⚠️ Important Reference Folder Warning

#### _examples/alrra
- **Fully functional working dotfiles project** compatible with macOS and Ubuntu
- **Trusted reference** for learning techniques and patterns
- **Uses source methodology** that we will NOT adopt (scripts source each other)
- **Learn from it** but adapt to our main() function pattern

#### _legacy
- **Fully functional working dotfiles project** based on older version of _examples/alrra
- **Targets multiple Ubuntu versions and WSL** in addition to macOS
- **Currently in production use** but follows outdated practices
- **Uses source methodology** that we will NOT adopt (not testable in isolation)
- **Learn from it** but convert to self-contained scripts

#### _archive
- **Bloated, undocumented auto-generated code** - DO NOT TRUST OR COPY
- Previous failed attempt at automation
- Kept for reference of what NOT to do

**Important**: While _examples/alrra and _legacy are functional projects we can learn from, they use a source-based approach where scripts source other scripts. We will NOT use this pattern as it makes scripts difficult to test in isolation. Instead, every script we create will have a self-contained main() function and be directly executable from the command line.

### Important Design Patterns

1. **All scripts must be idempotent** - capable of being executed multiple times safely
2. **Every script uses a main() function** - never source scripts, always execute directly
3. **Scripts must check before modifying** - verify current state before making changes
4. **Small, focused files** - keep scripts under 200 lines

**Script Methodology**: Unlike the source-based approach in _examples/alrra and _legacy (where scripts source other scripts), our scripts are self-contained with a main() function. This makes each script testable in isolation and callable directly from the command line.

### Script Pattern Template

```bash
#!/usr/bin/env bash

# Script functions here...

main() {
    # All script logic goes here
    # Check if configuration exists before adding
    # Make idempotent changes only
}

# Execute main function when script is run directly
main "$@"
```

## Development Workflow

1. Write scripts that will install/configure on target systems
2. Use conditional logic to ensure idempotency
3. Document what scripts will do when deployed
4. Scripts will be executed via one-liner commands on target systems

## Key Implementation Guidelines

### Idempotency Examples (CRITICAL)

```bash
# BAD: Blindly appends (creates duplicates on each run)
echo "export PATH=$PATH:/new/path" >> ~/.bashrc

# GOOD: Check if already present before adding
if ! grep -q "/new/path" ~/.bashrc; then
    echo "export PATH=$PATH:/new/path" >> ~/.bashrc
fi

# BAD: Always creates directory (may error if exists)
mkdir ~/my-directory

# GOOD: Check existence first
if [ ! -d ~/my-directory ]; then
    mkdir ~/my-directory
fi

# BETTER: Use mkdir -p (idempotent by design)
mkdir -p ~/my-directory
```

**Remember**: Users will run these scripts repeatedly. Every script must handle being run 1 time or 100 times with the same result.

### Platform Strategy

- **Current Target Platforms**: 
  - Windows WSL running Ubuntu (text-based development)
  - Ubuntu Server 22.04 LTS (SSH/terminal development)
  - macOS 15 (Sequoia) (GUI and terminal development)
- **Future Platforms** (after initial three are complete):
  - RHEL (Red Hat Enterprise Linux)
  - AWS Linux
- **Independent Implementations**: Each platform has its own complete, self-contained scripts
- **Code Duplication is Acceptable**: We prioritize simplicity over DRY principles
- **No Adaptive Configurations**: Each platform folder contains platform-specific versions of all scripts
- **Single Entry Point with Detection**: Only `src/setup.sh` performs platform detection to route to the correct platform folder
- **No Other Dynamic Platform Detection**: All other scripts are written specifically for their target OS
- **Common Folder**: Limited to truly universal functionality with no OS-specific behavior
- **Software Installation**: Developer tools installed per-platform with OS-specific methods:
  - **All platforms**: Git, Vim/Neovim as primary IDE, Node.js, npm, Java JDK, Docker, build tools
  - **macOS additions**: Supplementary VS Code, Homebrew packages, Docker Desktop
  - **Ubuntu/WSL**: Terminal multiplexers for enhanced productivity
- **WSL Considerations**: WSL Ubuntu scripts may need special handling for Windows interop features

## Repository Commands

Currently, this is a development repository with no build or test commands. Scripts are validated through:
- Code review and logic analysis
- Manual verification of script behavior
- Testing on actual target systems during deployment

## Deployment Model

Target systems will use a one-liner installation to transform a fresh OS into a complete developer workstation:

**macOS:**
```bash
bash -c "$(curl -LsS https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"
```

**Ubuntu/WSL:**
```bash
bash -c "$(wget -qO - https://raw.github.com/fredlackey/dotfiles-sandbox/main/src/setup.sh)"
```

The setup script will automatically:
1. Download the repository as a tarball (no git required initially)
2. Extract the archive to `~/dotfiles` using built-in tar command
3. Detect the operating system
4. Install git and other essential tools via platform package managers
5. Initialize the extracted folder as a git repository for future updates
6. Execute the appropriate platform-specific setup
7. Install complete development stack:
   - Programming languages (Node.js, Java, Python)
   - Build tools (npm, Maven, Gradle, Make)
   - Container tools (Docker, docker-compose)
   - IDEs/Editors (Vim/Neovim as primary IDE everywhere, supplementary VS Code on macOS)
   - Database clients and tools
   - Cloud CLIs and deployment tools
   - Developer productivity utilities

Updates are applied via `git pull` followed by re-running `src/setup.sh`.
- The repo will be hosted at https://github.com/FredLackey/dotfiles-sandbox during development.  Once perfected it will be replace the existing repo at https://github.com/FredLackey/dotfiles
- If any part of the scripts fail during installation a failure should be reported and processing stop.