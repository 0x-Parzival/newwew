# Kalki OS Centralized Package Lists

This directory contains the package lists for all Kalki OS profiles (ultimate, minimal, minimal-auto, etc.).

## Structure
- Each profile has its own `packages.x86_64` file.
- All required packages for the profile (base system, AI, avatars, dharmic tools, security, etc.) should be listed here.
- Specialized package lists (ai, avatar, dharmic, security) can be maintained as separate files and included via build scripts if needed.

## How to Add Packages
- To add a package for all profiles, add it to each `packages.x86_64` as needed.
- To add a package for a specific feature (AI, avatar, etc.), add it to the relevant profile(s) and document it in this README.

## Maintenance
- Keep package lists deduplicated and up to date.
- Use comments to group packages by function (base, AI, avatar, etc.).
- Review and update before each release. 