# Dotfiles Sandbox

A modern, streamlined approach to dotfiles management targeting **Z Shell (ZSH)** with near-single-command setup.

## Overview

This repository represents a new dotfiles approach designed for simplicity and efficiency. Unlike traditional multi-step dotfiles setups, this project aims to achieve complete environment configuration with as close to a single ZSH command as possible.

## Target Shell

**Z Shell (ZSH)** - This dotfiles configuration is specifically designed for and targets ZSH as the primary shell environment.

## Design Philosophy

- **Simplicity First**: Minimize the number of commands needed for complete setup
- **ZSH Native**: Built specifically for Z Shell, leveraging its advanced features
- **Idempotent Operations**: Safe to run multiple times without side effects
- **Modern Tooling**: Focus on contemporary development tools and workflows

## Quick Start

> ⚠️ **Development Notice**: This is currently in active development. The single-command setup is being refined.

```zsh
curl -fsSL https://raw.githubusercontent.com/fredlackey/dotfiles-sandbox/main/draft/setup.zsh | zsh
```

## Repository Structure

```
├── draft/          # Active development of the new ZSH approach
├── alrra/          # Reference implementation (Cătălin's dotfiles)
├── legacy/         # Previous multi-platform bash-based implementations
└── README.md       # This file
```

## Development Status

This project is currently in **active development**. The goal is to create a dotfiles solution that:

1. **Targets ZSH exclusively** - No bash compatibility layer needed
2. **Single command setup** - Minimal user interaction required
3. **Modern defaults** - Contemporary tools and configurations
4. **Idempotent execution** - Safe to run repeatedly
5. **Focused scope** - Essential tools only, no bloat

## Comparison with Legacy Approaches

| Aspect | Legacy (bash-based) | New ZSH Approach |
|--------|-------------------|------------------|
| **Target Shell** | Bash + ZSH compatibility | ZSH native |
| **Setup Commands** | Multiple steps | Single command |
| **Platform Support** | macOS + Ubuntu | macOS focused |
| **Complexity** | High (200+ files) | Minimal |
| **Maintenance** | Complex multi-OS | Streamlined |

## Contributing

This is a personal dotfiles sandbox for experimentation. The `draft/` directory contains the active development of the new approach.

## License

MIT License - See individual directories for specific licensing information.

---

**Note**: The `alrra/` and `legacy/` directories contain reference implementations and previous approaches. The active development is happening in the `draft/` directory as we work toward the single-command ZSH setup goal.
