# Kalki OS – AI-Enhanced Arch Linux Live ISO

[![Status](https://img.shields.io/badge/status-beta-yellow.svg)](https://github.com/kalki-os/kalki-os/releases)
[![Build Status](https://github.com/kalki-os/kalki-os/actions/workflows/ci.yml/badge.svg)](https://github.com/kalki-os/kalki-os/actions)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](https://opensource.org/licenses/GPL-3.0)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://docs.kalki.os)

*Kalki OS* is a reproducible Arch-based live distribution that boots straight into a modern Wayland desktop (Hyprland) with an integrated AI assistant. The system includes a lightweight AI model for installation assistance and system troubleshooting, with the capability to fetch and run additional AI models on first boot.

## 📋 Table of Contents

- [🚀 Features](#-features)
- [🏗️ Repository Structure](#-repository-structure)
- [⚡ Quick Start](#-quick-start)
- [🔧 Building from Source](#-building-from-source)
- [🖥️ Screenshot](#️-screenshot)
- [🤖 AI Assistant](#-ai-assistant)
- [🔧 Technologies](#-technologies)
- [📦 Installation](#-installation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🚀 Features

* **Fast** – zen kernel, PipeWire, Wayland, zram.
* **AI-ready** – Integrated TinyLlama AI assistant with Ollama + OMNet support
* **Hardened** – systemd-sandboxed services, sudoers locked down, no root login on TTY
* **Modular** – Clean, maintainable structure following Linux distribution best practices
* **100% Reproducible** – Deterministic builds with full dependency tracking

## 🏗️ Repository Structure

```
.
├── build/                # Build system and CI/CD
│   ├── iso/              # ISO build configuration
│   ├── packaging/        # Package build scripts
│   └── ci/               # CI/CD configurations
├── distro/               # Distribution components
│   ├── profiles/         # ISO profiles (kalki-ultimate, kalki-minimal)
│   ├── overlays/         # System overlays (ai, ui, security, etc.)
│   └── packages/         # Package lists (*.pkglist)
├── src/                  # Source code
│   ├── ai-components/    # AI integration code
│   ├── avatar-system/    # Avatar system implementation
│   ├── security-layer/   # Security tools and configurations
│   └── tools/            # Command-line utilities
├── tests/                # Test suites
│   ├── integration/      # Integration tests
│   ├── performance/      # Performance benchmarks
│   └── security/         # Security tests
├── docs/                 # Documentation
├── scripts/              # Maintenance and helper scripts
└── assets/               # Media assets (wallpapers, icons)
```

## ⚡ Quick Start

### Prerequisites

- x86_64 compatible computer with at least 4GB RAM
- 20GB free disk space
- Internet connection (for initial setup)

### Building the ISO

1. Clone the repository:
   ```bash
   git clone https://github.com/kalki-os/kalki-os.git
   cd kalki-os
   ```

2. Install build dependencies:
   ```bash
   sudo pacman -Syu --needed archiso mkinitcpio-archiso git
   ```

3. Build the ISO:
   ```bash
   cd build/iso
   make
   ```

4. The ISO will be available in the `out/` directory.

### Running in QEMU (for testing)

```bash
make run
```

## 🔧 Building from Source

### Available Build Profiles

- `kalki-ultimate`: Full-featured ISO with all components (default)
- `kalki-minimal`: Minimal ISO with core functionality

### Custom Build

```bash
# Build a specific profile
make ISO_NAME=kalki-minimal

# Clean build artifacts
make clean

# Run tests
make test
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Arch Linux](https://www.archlinux.org/) for the amazing base system
- [Hyprland](https://hyprland.org/) for the beautiful Wayland compositor
- [Ollama](https://ollama.ai/) for the AI model serving infrastructure
- All our amazing contributors!

[![Status](https://img.shields.io/badge/status-beta-yellow.svg)](https://github.com/kalki-os/kalki-os/releases)
[![Build Status](https://github.com/kalki-os/kalki-os/actions/workflows/ci.yml/badge.svg)](https://github.com/kalki-os/kalki-os/actions)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](https://opensource.org/licenses/GPL-3.0)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://docs.kalki.os)

*Kalki OS* is a reproducible Arch-based live distribution that boots straight into a modern Wayland desktop (Hyprland) with an integrated AI assistant. The system includes a lightweight AI model for installation assistance and system troubleshooting, with the capability to fetch and run additional AI models on first boot.

## 📋 Table of Contents

- [🚀 Features](#-features)
- [📋 Requirements](#-requirements)
- [⚡ Quick Start](#-quick-start)
- [🖥️ Screenshot](#️-screenshot)
- [🤖 AI Assistant](#-ai-assistant)
- [🔧 Technologies](#-technologies)
- [📦 Installation](#-installation)
- [🔍 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)

---

## 🚀 Features

*Kalki OS* is a reproducible Arch-based live distribution that boots straight into a modern Wayland desktop (Hyprland) with an integrated AI assistant. The system includes a lightweight AI model for installation assistance and system troubleshooting, with the capability to fetch and run additional AI models on first boot.

---

* **Fast** – zen kernel, PipeWire, Wayland, zram.
* **AI-ready** – Integrated TinyLlama AI assistant for installation help and troubleshooting, with optional Ollama + OMNet support for advanced AI features.
* **Hardened** – systemd-sandboxed services, sudoers locked down, no root login on TTY.
* **Rescue friendly** – btrfs, snapper, networking and disk tools pre-installed.
* **100 % Arch** – no custom repos; everything can be rebuilt from upstream packages.

## 🖥️ Screenshot

![Kalki OS Desktop](docs/images/kalki-desktop.png)
*Hyprland desktop with AI terminal and system monitoring*

## 🔧 Technologies

- **Kernel**: Linux-zen
- **Display Server**: Wayland
- **Window Manager**: Hyprland
- **Audio**: PipeWire
- **AI Framework**: Ollama + OMNet
- **Package Manager**: pacman + AUR helper (yay)
- **Containerization**: systemd-nspawn, podman
- **Build System**: mkarchiso
- **Version Control**: git
- **Documentation**: Markdown, mkdocs

---

## 📋 Requirements

### System Requirements

| Use-case | RAM | Disk | Notes |
|----------|-----|------|-------|
| Building ISO | 4 GiB (min) | 12 GiB | 16 GiB+ recommended for AI features |
| Running live with AI | 4 GiB (min) | — | 8 GiB+ recommended for best performance |
| Running live (minimal) | 2 GiB (min) | — | AI features disabled |

### AI Assistant Requirements

- **CPU**: x86_64 (64-bit) processor with SSE4.2 support
- **GPU**: Optional, but recommended for better performance
- **Disk Space**: Additional ~700MB for the AI model
- **Internet**: Required for initial model download (if not pre-included)

The build must run on an Arch-based host (or Arch container) with internet access to download the AI model.

---

## ⚡ Quick Start

### Building the ISO

```bash
# 1. Clone the repository
$ git clone https://github.com/youruser/kalki-os.git && cd kalki-os

# 2. Fix mirrors & keyring (requires sudo)
$ sudo scripts/fix-repos.sh

# 3. Build the full ISO with AI assistant
$ ./build-kalki-phase4.sh

# 4. Test in a VM with KVM acceleration (recommended)
$ qemu-system-x86_64 -m 8G -smp 4 -cdrom out/kalki-os-*.iso -enable-kvm

# For development without AI tools
$ ./build-kalki-iso.sh --dev --validate
```

### Using the AI Assistant

The AI assistant is integrated into the live environment and can be accessed through the terminal:

```bash
# Start interactive installation
kia

# Get help with specific issues (natural language)
kia "My installation failed"
kia "Network not working"
kia "Disk not detected"

# Advanced diagnostics
kia --diagnose       # Comprehensive system check
kia --hardware-info  # Detailed hardware report
kia --log-analyze    # Analyze system logs

# Show help and usage information
kia --help
```

### Common Use Cases

1. **Installation Assistance**
   ```
   kia "Help me install Kalki OS"
   ```

2. **Troubleshooting**
   ```
   kia "My system won't boot after installation"
   kia "WiFi is not connecting"
   kia "Screen resolution is incorrect"
   ```

3. **System Information**
   ```
   kia "What hardware do I have?"
   kia "Check system resources"
   kia "Show disk usage"
   ```

## 🧠 AI Assistant Features

### Intelligent Installation Management

Kalki Installation Assistant (KIA) provides comprehensive system management capabilities:
- **Real-time Issue Diagnosis**: Analyzes system state and user-reported problems
- **Hardware Compatibility Checking**: Verifies system requirements and suggests optimizations
- **Step-by-step Guidance**: Interactive walkthrough of the installation process
- **Contextual Help**: Provides relevant assistance based on current installation phase
- **Automated System Analysis**: Gathers and interprets system information automatically

### Advanced Troubleshooting Engine

The embedded AI assistant excels at:
- **Pattern Recognition**: Identifies common and complex installation issues
- **System Log Analysis**: Parses logs to diagnose problems accurately
- **Hardware Failure Detection**: Identifies potential hardware compatibility issues
- **Dependency Resolution**: Helps resolve package conflicts and missing dependencies
- **Hardware-specific Recommendations**: Suggests appropriate drivers and configurations

### Interactive User Experience

- **Natural Language Interface**: Understands user queries in plain English
- **Conversational Interaction**: Maintains context during troubleshooting sessions
- **Progressive Disclosure**: Presents information in digestible steps
- **Visual Feedback**: Clear progress indicators and status updates
- **Error Recovery**: Provides actionable solutions when issues occur

### Offline-First Architecture

- **Local Processing**: Core functionality works without internet
- **Lightweight Model**: Optimized for performance on modest hardware
- **Graceful Degradation**: Falls back to rule-based assistance when needed
- **Extensible Design**: Can integrate with additional AI models and tools

## 🤖 Default LLM Configuration

Kalki OS comes pre-configured with powerful open-weight language models for offline AI capabilities. The system uses a tiered approach to balance performance and resource usage.

### Primary Default Models

| Model | Size | Purpose | Quantization |
|-------|------|----------|--------------|
| Dolphin-Mixtral 8x7B | 26.44 GB (Q4_K_M) | General conversation, coding, creativity | Q4_K_M |
| DeepSeek-R1 8B | 4.7 GB (Q4_K_M) | Reasoning, system management | Q4_K_M |

### Model Specifications

#### Dolphin-Mixtral 8x7B
- 46.7B parameters with Mixtral architecture
- 32K context window for comprehensive conversations
- Excellent coding capabilities with specialized training
- Multiple quantization options available

#### DeepSeek-R1 8B
- Distilled reasoning model with excellent performance
- Optimized for system tasks and troubleshooting
- MIT License for commercial use and modifications
- Multiple variants available (1.5B to 70B parameters)

### Implementation Details

```bash
# Model directory structure
/opt/kalki/models/
  ├── default/           # Core models included in ISO
  │   ├── dolphin-mixtral-8x7b-Q4_K_M.gguf
  │   └── deepseek-r1-8b-Q4_K_M.gguf
  └── specialized/       # Additional models (downloaded as needed)
```

### Ollama Configuration

The system uses Ollama for model management with the following default configuration:

```json
{
  "default_models": {
    "primary": "dolphin-mixtral:8x7b",
    "reasoning": "deepseek-r1:8b",
    "fallback": "deepseek-r1:1.5b"
  },
  "model_assignments": {
    "chill-pig": "dolphin-mixtral:8x7b",
    "krix": "deepseek-r1:8b",
    "mushak": "deepseek-r1:8b",
    "general": "dolphin-mixtral:8x7b"
  }
}
```

### Avatar-Specific Model Routing

Kalki OS intelligently routes requests to the most appropriate model based on the active avatar and task type:

| Avatar | Default Model | Rationale |
|--------|---------------|------------|
| Chill Pig | Dolphin-Mixtral 8x7B | Emotional intelligence and empathy training |
| Krix, Mushak, Nag | DeepSeek-R1 8B | Superior reasoning for system tasks |
| Bunni (Creative) | Dolphin-Mixtral 8x7B | Enhanced creative writing capabilities |
| General Conversation | Dolphin-Mixtral 8x7B | Broad conversational abilities |

### Progressive Enhancement Strategy

Kalki OS implements an intelligent model management system that adapts to available resources and connectivity:

```bash
# Model expansion script (runs on first network connection)
/opt/kalki/scripts/expand-ai-models.sh
```

This script automatically enhances the system's capabilities when internet becomes available:

```bash
#!/bin/bash
if ping -c 1 google.com >/dev/null 2>&1; then
    echo "🌐 Internet detected - Expanding AI model library..."
    
    # Download specialized models for specific avatars
    ollama pull codellama:7b      # Enhanced coding for Mushak
    ollama pull mistral:7b        # Alternative lightweight option
    ollama pull deepseek-r1:32b   # More powerful reasoning when needed
else
    echo "📱 Operating in offline mode with default models"
fi
```

### Model Management Commands

```bash
# Check active models
kalki-models list

# Download additional models
kalki-models install codellama:7b

# Set default model for an avatar
kalki-models set-avatar mushak deepseek-r1:8b
```

## 🌀 Kalki OS Phase 5: Complete Avatar System Development

### Overview: Implementing the 12 Dharmic Avatars

Phase 5 focuses on fully implementing Kalki OS's revolutionary 12-avatar system, transforming your AI-integrated foundation into a comprehensive dharmic computing platform. This phase builds specialized AI agents with unique personalities, capabilities, and tools that work seamlessly within the OMNet neural core architecture.

The avatar system represents a breakthrough in multi-agent AI architecture, where each avatar serves as a specialized expert while maintaining the ability to collaborate on complex tasks. Unlike traditional single-agent systems that suffer from endless execution loops and lack of specialization, Kalki OS's multi-agent approach enables sophisticated task delegation and domain expertise.

## 🛠️ Enhanced Avatar Framework Development

### Advanced Avatar Configuration System

Kalki OS implements a comprehensive framework that supports personality-driven AI interactions with specialized model assignments. Each avatar features distinct behavioral patterns, specialized knowledge domains, and unique interaction styles that reflect their dharmic roles.

#### Directory Structure
```bash
/opt/kalki/avatars/
├── personalities/  # Avatar personality configurations
├── tools/         # Specialized tools for each avatar
├── models/        # Avatar-specific model configurations
└── workflows/     # Task-specific workflows and automations
```

#### Example Avatar Configuration

```json
{
  "mushak": {
    "name": "Mushak - The Swift Debugger",
    "specialty": "Code analysis, system diagnostics, rapid troubleshooting",
    "personality": "analytical, precise, energetic, detail-oriented",
    "model_primary": "deepseek-r1:8b",
    "model_fallback": "dolphin-mixtral:8x7b",
    "tools": ["debugger", "log-analyzer", "performance-monitor"],
    "capabilities": [
      "real-time error detection",
      "code optimization suggestions",
      "system performance analysis",
      "memory leak detection"
    ],
    "interaction_style": {
      "response_speed": "fast",
      "technical_depth": "high",
      "explanation_style": "concise",
      "emoji_usage": "technical (⚡🔍🐛)"
    }
  },
  "nandi": {
    "name": "Nandi - The Stable Guardian",
    "specialty": "Financial management, system stability, resource optimization",
    "personality": "reliable, methodical, protective, wise",
    "model_primary": "dolphin-mixtral:8x7b",
    "model_fallback": "deepseek-r1:8b",
    "tools": ["budget-tracker", "resource-monitor", "stability-checker"],
    "capabilities": [
      "expense tracking and analysis",
      "system resource optimization",
      "financial advice and planning",
      "stability monitoring"
    ],
    "interaction_style": {
      "response_speed": "measured",
      "technical_depth": "medium",
      "explanation_style": "thorough",
      "emoji_usage": "stable (🛡️💰📊)"
    }
  }
}
```

### Key Features

1. **Personality-Driven Interactions**
   - Unique response styles and tones for each avatar
   - Specialized knowledge domains and expertise
   - Context-aware behavior adaptation

2. **Dynamic Tool Integration**
   - Avatar-specific toolkits
   - On-demand capability loading
   - Seamless tool chaining

3. **Intelligent Model Routing**
   - Primary and fallback model assignments
   - Task-optimized model selection
   - Resource-aware model loading

4. **Consistent User Experience**
   - Unified interaction patterns
   - Predictable behavior
   - Clear communication of capabilities

## 🏗️ System Architecture

### OMNet Neural Core

Intelligent request routing based on task type and avatar requirements:

```python
def select_model(request_type, avatar, complexity):
    """Route requests to optimal model based on context"""
    # System and reasoning tasks
    if request_type in ['reasoning', 'debugging', 'system_analysis']:
        return 'deepseek-r1:8b'
    # Creative and conversational tasks
    elif request_type in ['conversation', 'creativity', 'emotional_support']:
        return 'dolphin-mixtral:8x7b'
    # Default fallback
    return 'dolphin-mixtral:8x7b'
```

### Dharmic Computing Integration

This architecture embodies Kalki OS's principles through:

1. **Conscious Resource Usage**
   - Efficient model quantization
   - Smart memory management
   - On-demand loading

2. **Offline-First Design**
   - Full functionality without internet
   - Local processing for privacy
   - Graceful degradation

3. **Progressive Enhancement**
   - Start with capable defaults
   - Expand based on resources
   - Continuous improvement

4. **Balanced Intelligence**
   - DeepSeek-R1 for reasoning
   - Dolphin-Mixtral for creativity
   - Unified through OMNet

## 📊 Resource Impact and Performance

### System Requirements

| Component | Size | Memory Usage | CPU Threads | Notes |
|-----------|------|--------------|-------------|-------|
| TinyLlama Model | ~670MB | 800MB-1.2GB | 2-4 | Q4_K_M quantization |
| Python Dependencies | ~150MB | 50-100MB | 1-2 | llama-cpp-python, etc. |
| Assistant Framework | ~50MB | 50-100MB | 1-2 | Core scripts and utilities |
| **Total** | **~870MB** | **900MB-1.4GB** | **2-4** | **15-20% ISO size increase** |

### Performance Optimization

- **Efficient Inference**: Optimized for modern x86_64 processors with SSE4.2
- **Progressive Loading**: Only loads AI components when needed
- **Graceful Degradation**: Falls back to rule-based system if resources are constrained
- **Background Processing**: Non-blocking operations for responsive UI

### Alternative Configurations

| Option | Size | Memory | Best For |
|--------|------|--------|-----------|
| TinyLlama 1.1B (Q4_K_M) | 670MB | 1.2GB | Balanced performance/size |
| DistilGPT-2 | 250MB | 500MB | Lower resource systems |
| Rule-based Only | 10MB | 50MB | Minimal systems |
| Hybrid (Download) | 10MB+ | Varies | Network-connected installs |

## 🕉️ Dharmic Computing Alignment

### Core Principles

1. **Compassionate Assistance**
   - Patient, non-judgmental guidance
   - Clear, step-by-step instructions
   - Multiple solution paths for different skill levels

2. **Mindful Resource Usage**
   - Efficient model quantization
   - On-demand resource loading
   - Minimal background impact

3. **Wisdom Through Experience**
   - Learns from common installation patterns
   - Shares contextual knowledge
   - Explains technical concepts clearly

4. **Balanced Complexity**
   - Simple interfaces for common tasks
   - Advanced options when needed
   - Clear documentation and help

### Avatar System Integration

The AI assistant works in harmony with Kalki OS's avatar system:

- **Mushak (Debugging)**: Assists with troubleshooting and error resolution
- **Nandi (Stability)**: Provides system health monitoring and optimization tips
- **Shera (Security)**: Guides secure configuration and best practices

## 🤖 AI Model Details

| Model | Size | Parameters | Quantization | Context |
|-------|------|------------|--------------|---------|
| TinyLlama 1.1B | ~670MB | 1.1B | Q4_K_M | 2048 tokens |

*Note: The model is optimized for installation assistance and system troubleshooting, balancing performance and resource usage.*

## 🚀 Implementation Timeline

### Immediate Deployment Steps

1. **Prerequisites**
   - Ensure you have at least 2GB free disk space
   - Stable internet connection for model download
   - Root or sudo privileges

2. **Quick Start**
   ```bash
   # Navigate to your project directory
   cd /path/to/kalki-os
   
   # Make the setup script executable
   chmod +x scripts/setup-ai-assistant.sh
   
   # Run the setup script (requires sudo)
   sudo ./scripts/setup-ai-assistant.sh
   
   # Build the enhanced ISO
   ./build-kalki-phase4.sh
   ```

3. **Verification**
   ```bash
   # Test the assistant in the live environment
   kia --test
   
   # Check system integration
   systemctl status kalki-assistant
   ```

## ✨ Expected Outcomes

### Enhanced User Experience
- **Intelligent Troubleshooting**: AI-powered diagnosis of installation issues
- **Context-Aware Help**: Guidance adapts to your current installation phase
- **Automated System Analysis**: Automatic detection of hardware and configuration issues
- **Offline Capabilities**: Full functionality without internet dependency
- **Comprehensive Logging**: Detailed records for support and improvement

### Technical Improvements
- **Streamlined Installation**: Reduced user errors and retries
- **Proactive Problem Prevention**: Early detection of potential issues
- **Unified Support Experience**: Consistent assistance across installation phases
- **Extensible Architecture**: Easy to update and enhance with new capabilities

### Dharmic Computing Impact
- **Accessible Technology**: Makes Linux installation approachable for all skill levels
- **Mindful Assistance**: Provides just enough guidance without overwhelming users
- **Compassionate Support**: Patient, clear instructions for complex procedures
- **Balanced Automation**: Combines AI intelligence with user control

## 🌟 Getting Started with the Assistant

In the live environment, simply type `kia` in the terminal to start the interactive assistant. For specific help:

```bash
# General installation help
kia "Help me install Kalki OS"

# Troubleshoot an issue
kia "My system won't boot after installation"

# Get system information
kia --system-info

# Run diagnostics
kia --diagnose
```

*The AI assistant is designed to be intuitive and helpful, guiding you through the entire installation process with patience and clarity.*

### Build Options

```bash
# Resume interrupted build
$ ./build-kalki-iso.sh --resume

# Clean build (delete work directory)
$ ./build-kalki-iso.sh --clean

# Development mode (skip AI tools)
$ ./build-kalki-iso.sh --dev

# Build without validation (faster)
$ ./build-kalki-iso.sh --no-validate
```

### VM Testing Features

The `test-kalki-vm.sh` script provides several options for testing Kalki OS in different configurations:

```bash
# Basic usage with KVM acceleration (recommended)
sudo ./scripts/test-kalki-vm.sh

# Advanced usage examples:
# Run in headless mode (no GUI)
./scripts/test-kalki-vm.sh --no-graphics

# Disable audio (useful if Plymouth hangs)
./scripts/test-kalki-vm.sh --no-audio

# Enable SSH port forwarding (host:2222 → guest:22)
./scripts/test-kalki-vm.sh --ssh-forward

# Boot with custom kernel parameters
./scripts/test-kalki-vm.sh --boot-args "systemd.unit=rescue.target"
```

### KVM Acceleration & Graphics

For best performance, enable KVM acceleration in your BIOS/UEFI settings.

```bash
# Check if your CPU supports virtualization (should output "Supported")
$ egrep -q 'vmx|svm' /proc/cpuinfo && echo "Supported" || echo "Not supported"

# Load KVM modules (as root)
$ sudo modprobe kvm_intel    # For Intel CPUs
# OR
$ sudo modprobe kvm_amd      # For AMD CPUs

# Install required graphics libraries
$ sudo pacman -S libvirglrenderer mesa virtio-video
```

### Audio Configuration

The VM uses ALSA for audio by default to avoid PulseAudio-related issues. If you need audio in the VM, ensure your host system has ALSA configured.

```bash
# Check if ALSA is working
$ aplay -l

# Install ALSA utilities (if needed)
$ sudo pacman -S alsa-utils
```

The freshly built image lives in `iso-profile/kalki-base/out/`.

---

## 🗂️ Repository Layout

```
├── build-kalki-iso.sh            # Enhanced build script with resume support
├── iso-profile/                   # mkarchiso profile
│   └── kalki-base/
│       ├── airootfs/              # Files copied into live FS
│       ├── packages.x86_64        # Package manifest
│       └── profiledef.sh          # mkarchiso config
├── ai-tools/                      # AI tools and utilities
│   ├── krix-term/                # Terminal AI assistant
│   └── ...
├── scripts/
│   ├── fix-repos.sh               # Mirror + keyring healer
│   ├── setup-ai-tools.sh         # AI tools installer
│   ├── test-kalki-vm.sh          # QEMU/KVM wrapper
│   └── update-mirrorlist.sh      # Fallback mirror helper
├── work/                         # Build directory (created during build)
├── out/                          # Output directory for ISOs
├── docs/                         # Extended docs & assets
└── README.md                     # You are here
```

---

## 🛠️ Troubleshooting

| Symptom | Fix |
|---------|-----|
| `unknown packages` error | Edit `iso-profile/.../packages.x86_64` or wait for package to re-enter repos. |
| Keyring / PGP failures | `sudo pacman -Sy archlinux-keyring` or re-run `scripts/fix-repos.sh`. |
| KVM not available | Enable virtualization in BIOS/UEFI and load KVM modules with `sudo modprobe kvm_intel` (Intel) or `sudo modprobe kvm_amd` (AMD) |
| QEMU fails to start | Ensure `qemu-full` or `qemu-system-x86` is installed and your user has access to `/dev/kvm` |
| Slow VM performance | Use KVM acceleration and allocate more CPU cores/memory with `--cpus` and `--memory` options |
| OpenGL errors | Install `libvirglrenderer` and `mesa`: `sudo pacman -S libvirglrenderer mesa virtio-video` |
| Audio not working | Ensure ALSA is configured on host, check with `aplay -l` |
| Plymouth hangs on boot | Try `--no-audio` or boot with `--boot-args "systemd.unit=multi-user.target"` |
| Display issues | Try `--no-graphics` or different display backends: `-display gtk`, `-display sdl` |
| Network issues | Use `--ssh-forward` for SSH access or check host firewall settings |
| Boot fails | Try `--boot-args "systemd.unit=rescue.target"` to enter rescue mode |
| Slow performance | Ensure KVM is enabled and allocate more resources with `--cpus`/`--memory` |
| Build fails | Check `work/build.log` for detailed error messages |
| AI tools not found | Run `./scripts/setup-ai-tools.sh` manually |
| Slow mirrors | Edit `--country` / `--latest` flags in `scripts/fix-repos.sh` |
| PipeWire vs PulseAudio | Ensure `pulseaudio` **not** listed when `pipewire-pulse` present |
| Missing dependencies | Run `sudo pacman -S mkarchiso qemu jq` |

More detail: `docs/TROUBLESHOOTING.md`.

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Arch Linux](https://www.archlinux.org/) for the amazing base system
- [Hyprland](https://hyprland.org/) for the beautiful Wayland compositor
- [Ollama](https://ollama.ai/) for the AI model framework
- All our amazing [contributors](CONTRIBUTORS.md)

---

📫 **Need help?** Join our [Matrix](https://matrix.to/#/#kalki-os:matrix.org) or open an [issue](https://github.com/kalki-os/kalki-os/issues).

[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in%20GitHub%20Codespaces-333?logo=github)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=kalki-os)

1. Fork ➜ feature branch.
2. Run `./build-ai-integrated-kalki.sh` – it must finish cleanly.
3. Conform to `shellcheck` + `shfmt` (`make lint fmt`).
4. Submit PR with clear motivation.

---

## 📜 License

MIT © 2025 Krix Collective
