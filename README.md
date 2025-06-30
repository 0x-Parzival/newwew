# Kalki OS Build System

## 🚀 Default Build Method: Arch Linux Docker Container

The recommended, reproducible way to build Kalki OS is to use the provided Docker container. This ensures all dependencies (including AUR packages) are installed in a clean, isolated environment.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Linux, macOS, or Windows)

### 2. Launch the Build Container
```bash
chmod +x run-arch-build-container.sh
./run-arch-build-container.sh
```
This will:
- Build a Docker image with all dependencies, AUR helper, and Python requirements
- Mount your project directory for seamless development
- Drop you into a ready-to-build shell as a non-root user

### 3. Run the GUI Build Launcher (Linux)
```bash
python3 kalki-build-gui.py
```
- The GUI will appear if you have X11 forwarding enabled (see below).

### 4. Run CLI Builds (Everywhere)
You can also run any build script directly:
```bash
bash kalki-os/build-minimal-iso.sh --skip-validations --verbose
```

### 5. GUI on macOS/Windows
- **Option 1: Use CLI builds (recommended for simplicity)**
- **Option 2: Use XQuartz (macOS) or VcXsrv/Xming (Windows) for X11 GUI support**
  - Start your X server (e.g., XQuartz on macOS)
  - Set DISPLAY in the container: `export DISPLAY=host.docker.internal:0`
  - Then run: `python3 kalki-build-gui.py`
- **Option 3: Use VNC (Recommended for full GUI support)**
  1. Install [TigerVNC Viewer](https://tigervnc.org/) on your host (macOS/Windows/Linux)
  2. In the Docker container, install and start the VNC server:
     ```bash
     sudo pacman -S --noconfirm tigervnc
     vncserver :1
     export DISPLAY=:1
     python3 kalki-build-gui.py
     ```
  3. On your host, connect to `localhost:5901` with TigerVNC Viewer.
  4. When done, stop the VNC server in the container:
     ```bash
     vncserver -kill :1
     ```

### 6. Why Use the Docker Container?
- Clean, reproducible builds
- No need to install Arch or dependencies on your host
- All AUR and Python dependencies handled automatically
- Works on Linux, macOS, and Windows

---

## Advanced: VM-based Build Environment
If you prefer a VM (e.g., VirtualBox, UTM), see `Vagrantfile` or ask for a VM setup script.

---

## Questions?
See the in-app Help/About, or visit [https://kalki-os.org](https://kalki-os.org) 