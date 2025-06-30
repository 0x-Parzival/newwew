# Kalki OS Dynamic Wallpaper System

## Overview
The dynamic wallpaper system in Kalki OS automatically changes the desktop background based on the time of day, creating a more immersive and responsive user experience. The system uses four different wallpapers for different times of the day:

- **Dawn** (5:00 AM - 7:59 AM)
- **Day** (8:00 AM - 4:59 PM)
- **Dusk** (5:00 PM - 7:59 PM)
- **Night** (8:00 PM - 4:59 AM)

## Features

- Automatic wallpaper rotation based on time of day
- Smooth transitions between wallpapers
- Systemd service for reliable operation
- User-configurable wallpaper sets
- Low resource usage

## Directory Structure

```
/opt/kalki/wallpapers/
├── dawn/       # Wallpapers for dawn
├── day/        # Wallpapers for daytime
├── dusk/       # Wallpapers for dusk
└── night/      # Wallpapers for nighttime
```

## Usage

### Manual Wallpaper Changes

To manually change the wallpaper to a specific time of day:

```bash
kalki-wallpaper dawn   # Set dawn wallpaper
kalki-wallpaper day    # Set day wallpaper
kalki-wallpaper dusk   # Set dusk wallpaper
kalki-wallpaper night  # Set night wallpaper
kalki-wallpaper auto   # Auto-detect and set based on time
```

### Adding Custom Wallpapers

1. Place your wallpaper images in the appropriate time-based directory:
   ```
   /opt/kalki/wallpapers/dawn/your-dawn-wallpaper.jpg
   /opt/kalki/wallpapers/day/your-day-wallpaper.jpg
   /opt/kalki/wallpapers/dusk/your-dusk-wallpaper.jpg
   /opt/kalki/wallpapers/night/your-night-wallpaper.jpg
   ```

2. Update the hyprpaper configuration if you want to use specific filenames:
   ```bash
   sudo nano /etc/skel/.config/hypr/hyprpaper.conf
   ```

### Systemd Services

The wallpaper system includes two systemd units:

- `kalki-wallpaper.service`: Applies the wallpaper change
- `kalki-wallpaper.timer`: Triggers the service hourly

#### Managing Services

Check status:
```bash
systemctl --user status kalki-wallpaper.timer
```

Manually trigger a wallpaper update:
```bash
systemctl --user start kalki-wallpaper.service
```

### Logs

Wallpaper changes are logged to:
```
~/.local/state/kalki/wallpaper.log
```

## Customization

### Changing Wallpaper Timing

Edit the `get_time_based_wallpaper` function in `/usr/local/bin/kalki-wallpaper` to adjust the time ranges for each wallpaper.

### Changing Wallpaper Transition Effects

Modify the hyprpaper configuration in `~/.config/hypr/hyprpaper.conf` to adjust transition effects and timing.

## Troubleshooting

### Wallpapers Not Changing

1. Check if the systemd timer is active:
   ```bash
   systemctl --user list-timers
   ```

2. Check the logs:
   ```bash
   journalctl --user -u kalki-wallpaper.service
   ```

3. Ensure the wallpaper directories have the correct permissions:
   ```bash
   sudo chown -R $USER:$USER /opt/kalki/wallpapers
   chmod -R 755 /opt/kalki/wallpapers
   ```

### Missing Dependencies

If you encounter missing dependencies, install them with:
```bash
sudo pacman -S imagemagick hyprpaper
```

## Development

### Adding New Features

1. Edit the main script:
   ```bash
   sudo nano /usr/local/bin/kalki-wallpaper
   ```

2. Reload systemd after making changes:
   ```bash
   systemctl --user daemon-reload
   systemctl --user restart kalki-wallpaper.timer
   ```

### Testing Changes

Test your changes by manually running the script with debug output:
```bash
/usr/local/bin/kalki-wallpaper auto --debug
```

## License

This wallpaper system is part of Kalki OS and is distributed under the GPL-3.0 license.
