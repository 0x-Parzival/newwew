# Kalki OS - Structured Build System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-green.svg)]()

> **Kalki OS** - A modern, agentic, modular Linux distribution with AI integration, avatar system, and dharmic applications.

## 🏗️ Project Structure

This project has been restructured to follow industry best practices for Linux distribution development:

```
kalki-os/
├── src/                          # Source code
│   ├── core/                     # Core OS components (ISO profiles, distro config)
│   ├── apps/                     # Dharmic applications (BunniWrite, DesignDeva, etc.)
│   ├── ai-system/               # AI integration components (Agent Zero, SEAL)
│   ├── avatar-system/           # Avatar personalities & logic
│   ├── security/                # Security hardening components
│   └── configs/                 # System configurations
├── build/                        # Build system
│   ├── scripts/                 # Build scripts (unified location)
│   ├── profiles/                # ISO profiles
│   ├── tools/                   # Build tools
│   └── ci/                      # CI/CD configuration (Docker, Vagrant)
├── dist/                        # Distribution artifacts
│   ├── iso/                     # Generated ISOs
│   ├── packages/                # Custom packages
│   └── keys/                    # Signing keys
├── docs/                        # Documentation
│   ├── user/                    # User documentation
│   ├── developer/               # Developer guides
│   ├── architecture/            # Architecture docs
│   └── release-notes/           # Release information
├── tests/                       # Testing framework
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── automation/              # Automated testing
├── tools/                       # Development tools
│   ├── gui/                     # GUI build tools
│   ├── validation/              # Validation scripts
│   └── utilities/               # Helper utilities
└── workspace/                   # Development workspace
    ├── work/                    # Build working directory
    ├── temp/                    # Temporary files
    └── cache/                   # Build cache
```

## 🚀 Quick Start

### Prerequisites
- Arch Linux environment (native or Docker)
- All dependencies installed (see `build/scripts/setup-build-env.sh`)

### GUI Build (Recommended)
```bash
python3 tools/gui/kalki-build-gui.py
```

### Command Line Build
```bash
# Setup environment (first time only)
bash build/scripts/setup-build-env.sh

# Build minimal ISO
bash build/scripts/build-minimal-iso.sh --verbose

# Build full Kalki OS
bash build/scripts/build-kalki.sh --verbose
```

### Docker Build (Cross-platform)
```bash
# Launch build container
bash build/ci/run-arch-build-container.sh

# Inside container, run build
bash build/scripts/build-kalki.sh
```

## 📦 Components Overview

### Core System
- **Base**: Arch Linux foundation with custom configurations
- **Desktop**: Hyprland compositor with custom theming
- **Security**: AppArmor, encryption, secure boot support

### AI Integration (Phase 4-5)
- **Agent Zero**: AI assistant framework
- **SEAL Learning**: Educational AI system
- **AI Terminal**: Integrated AI interface

### Avatar System (Phase 5)
- **Bunni**: Creative writing assistant
- **G.O.A.T.**: Design and productivity avatar
- **Roosty**: Time management avatar
- **DataTreya**: Data management avatar

### Dharmic Applications (Phase 6)
- **BunniWrite**: AI-assisted writing studio
- **DesignDeva**: Digital design studio with dharmic aesthetics
- **RoostyTime**: Natural rhythm-based time management
- **AppMantra**: Intelligent application store

### Security & Privacy (Phase 7)
- **DataTreya**: Encrypted storage and data management
- **AECH Blockchain**: Decentralized identity
- **Privacy Layer**: Advanced privacy protection

## 🛠️ Build Options

### Build Types
- `minimal`: Basic Kalki OS without advanced features
- `full`: Complete system with all phases
- `custom`: Selective feature inclusion

### Feature Flags
- `--no-ai`: Disable AI components
- `--no-avatars`: Disable avatar system
- `--no-security`: Disable security hardening
- `--no-dharmic-tools`: Disable dharmic applications

### Environment Variables
- `OUT_DIR`: Custom output directory
- `WORK_DIR`: Custom work directory
- `ENABLE_TESTING`: Run post-build tests

## 📋 Development Workflow

### Setting Up Development Environment
```bash
# Clone and setup
git clone <repository-url> kalki-os
cd kalki-os

# Setup build environment
bash build/scripts/setup-build-env.sh

# Run dependency checks
bash build/scripts/check-dependencies.sh
```

### Building Components
```bash
# Build individual components
bash build/scripts/build-ai-system.sh
bash build/scripts/build-avatar-system.sh
bash build/scripts/build-dharmic-apps.sh

# Validate builds
bash tools/validation/validate-phase5.sh
bash tools/validation/validate-phase6.sh
```

### Testing
```bash
# Unit tests
bash tests/unit/run-unit-tests.sh

# Integration tests
bash tests/integration/test-kalki-vm.sh

# Full system validation
bash build/scripts/validate-ai-integration.sh
```

## 📚 Documentation

- [User Guide](docs/user/) - End-user documentation
- [Developer Guide](docs/developer/) - Development instructions
- [Architecture](docs/architecture/) - System architecture
- [Release Notes](docs/release-notes/) - Version history

## 🤝 Contributing

1. Read [CONTRIBUTING.md](docs/CONTRIBUTING.md)
2. Fork the repository
3. Create a feature branch
4. Make your changes
5. Run tests: `bash tests/run-all-tests.sh`
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Arch Linux community
- AI/ML research community
- Dharmic computing philosophy contributors

---

**Note**: This is a restructured version of the Kalki OS project. All previous functionality has been preserved and organized according to modern software development practices.