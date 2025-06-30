# Kalki OS Hardware Compatibility & Troubleshooting

## Hardware Checks
- See `scripts/check-hardware.sh` for automated hardware compatibility checks.
- Required kernel modules: overlay, loop, squashfs
- UEFI firmware recommended (legacy BIOS supported with warnings)
- Minimum RAM: 2GB (4GB+ recommended)
- Sufficient disk space for build and install

## Known Issues & Workarounds
- Some older BIOS systems may require legacy boot mode
- Certain WiFi/Bluetooth chipsets may need extra drivers (see `docs/`)
- If a required kernel module is missing, ensure your kernel supports it and load with `modprobe <module>`

## Reporting Hardware Issues
- Run `scripts/check-hardware.sh` and include the output in your report
- Open an issue at: https://github.com/0x-Parzival/kalki/issues
- Or post in the community discussions

## Community & Support
- GitHub: https://github.com/0x-Parzival/kalki
- Issues: https://github.com/0x-Parzival/kalki/issues
- Discussions: https://github.com/0x-Parzival/kalki/discussions 