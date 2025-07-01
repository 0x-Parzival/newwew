# Kalki OS Memory Security Modules

This directory contains memory encryption and protection modules for Kalki OS.

- **src/memcrypt-module.c**: Kernel module for memory encryption.
- **src/memcryptd.c**: Daemon for memory encryption management.
- **Makefile**: Build instructions for the kernel module and daemon.
- **hooks/**: Integration hooks for system events.
- **services/**: Systemd or init scripts for service management.

## Integration
- Build and install the kernel module as part of the ISO or system setup.
- Enable the daemon and services for runtime protection. 