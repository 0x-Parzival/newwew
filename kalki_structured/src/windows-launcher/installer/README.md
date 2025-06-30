# Kalki OS Windows Launcher

A user-friendly Windows application for seamless, USB-free installation of Kalki OS. Designed for non-technical users to migrate from Windows to Kalki OS with just a few clicks.

## Features
- **Dual Boot (Recommended):** Safely install Kalki OS alongside Windows
- **Replace Windows:** Full migration to Kalki OS (advanced)
- **Try in VM:** Test Kalki OS in a virtual machine before installing
- **Automatic ISO Download:** Streams the latest Kalki OS ISO with progress
- **Disk Management:** Uses Windows APIs to shrink partitions and prepare for install
- **BCD Editing:** Adds Kalki OS to the Windows Boot Manager (undo supported)
- **Professional UI:** Step-by-step wizard, clear warnings, and progress feedback

## Build Instructions
- Requires [Visual Studio](https://visualstudio.microsoft.com/) (Community is fine) or `dotnet` CLI
- .NET 6.0+ recommended
- Open `KalkiLauncher.sln` or run:
  ```bash
  dotnet build
  ```

## Roadmap
- **Phase 1:** Basic launcher with dual boot, replace, and VM options (current)
- **Phase 2:** Web portal integration, video tutorials, smarter detection
- **Phase 3:** Seamless VM-to-native migration, advanced recovery tools

## Safety
- All operations are non-destructive by default (dual boot is recommended)
- Undo option for BCD changes
- Clear warnings before any disk changes

## Contributing & Feedback
- Issues and PRs welcome!
- See [Kalki OS GitHub](https://github.com/0x-Parzival/kalki) for main project
- Feedback and feature requests encouraged 