# Kalki OS Dharmic Tools & Applications Suite

This directory contains the core dharmic application suite for Kalki OS, integrating four essential applications that embody mindful computing and spiritual alignment. Each app is avatar-integrated and designed for a seamless, creative, and productive workflow.

## Applications

- **BunniWrite 🐰**: AI-assisted writing studio with mindful prompts and creative guidance (integrates with Bunni avatar).
- **DesignDeva 🎨**: Digital design studio with chakra color palettes, sacred geometry, and UI/UX tools (integrates with G.O.A.T. avatar).
- **RoostyTime 🐓**: Circadian rhythm-based scheduler and focus tool (integrates with Roosty avatar).
- **AppMantra 📱**: AI-curated app store with dharmic alignment scoring and avatar-guided discovery.

## Structure

```
/opt/kalki/
├── apps/
│   ├── bunniwrite/     # BunniWrite application
│   ├── designdeva/     # DesignDeva application
│   ├── roostytime/     # RoostyTime application
│   └── appmantra/      # AppMantra application
└── scripts/
    ├── integrate-dharmic-apps.sh  # Integration script
    └── app-startup-manager.sh     # Application manager
```

## Usage

- Unified launcher: `kalki-apps [bunni|design|time|store|list]`
- Individual aliases: `bunni`, `design`, `roostytime`, `appstore`
- Desktop entries are installed for each app.

## User Data

User-specific data is stored in `~/.kalki/apps/` and related subfolders.

## Validation

- All applications launch successfully
- Desktop entries are properly installed
- Command-line aliases work as expected
- User data directories are created on first run
- Applications integrate with their respective avatars
- All functionality works offline 