# Branding & First-Run Scripts

## prepare-branding-files.sh
- Prepares GRUB, Plymouth, wallpapers, and autostart entries for the ISO.
- Ensures all branding assets are in the correct locations in the ISO root.
- Installs a desktop entry for first boot that runs the first-run setup script.

## first-run-setup.sh
- Runs on first boot (OOBE).
- Removes itself from autostart after running.
- Handles branding setup and any other first-time setup tasks.

## Integration
- Both scripts are called during the ISO build process.
- The first-run script is executed automatically on the user's first login.

## Repo/Release Automation Scripts

### restructure-repo.sh
- Automates moving profiles, scripts, docs, and updating .gitignore for a professional repo layout.

### pre-build-setup.sh
- Updates package DB, installs all build dependencies, and verifies required tools.

### release-kalki.sh
- Automates ISO signing, publishing, and announcing.
- Checks for required tools and validates versioning. 