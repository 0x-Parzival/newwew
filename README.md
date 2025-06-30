# Kalki OS Build & VM Requirements

## Required Packages

### Arch Linux:
```
sudo pacman -S archiso mkinitcpio-archiso qemu libvirt virt-manager sudo shellcheck reflector plymouth ollama python3 jq zenity
```
### Debian/Ubuntu:
```
sudo apt-get install archiso qemu-kvm libvirt-daemon-system virt-manager sudo shellcheck reflector plymouth ollama python3 jq zenity
```
### Fedora:
```
sudo dnf install archiso qemu-kvm libvirt virt-manager sudo ShellCheck reflector plymouth ollama python3 jq zenity
```
### macOS (for dev only):
```
brew install shellcheck qemu python3 jq
```

## Build Steps
1. **Check dependencies:**  
   Run `scripts/check-dependencies.sh` before building.
2. **Build the ISO:**  
   ```sh
   ./build-minimal-iso.sh --verbose
   ```
   or for a full build:
   ```sh
   ./build-kalki.sh --verbose
   ```
3. **Run in a VM:**  
   - **QEMU:**  
     ```sh
     ./test-kalki-vm.sh --ram 8G --cpus 4
     ```
   - **Libvirt/virt-manager:**  
     ```sh
     cd kalki-os/scripts
     ./generate-vm-xml.sh --ram 8 --cpus 4 --launch
     ```
     Or import the generated XML in virt-manager.

## Troubleshooting
- **Missing dependencies:**  
  The scripts will tell you what's missing and how to install it.
- **Permission issues:**  
  Do not run build scripts as root. Use `sudo` only when prompted.
- **VM issues:**  
  Ensure virtualization is enabled in BIOS and you have enough RAM/CPU.

## Shell Script Linting
For best practices and error prevention, install `shellcheck` and run:
```sh
find . -name '*.sh' -exec shellcheck {} +
```

For more, see the KALKI_OS_HANDBOOK.txt and scripts/README.md. 