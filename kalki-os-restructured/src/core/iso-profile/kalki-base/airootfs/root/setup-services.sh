#!/bin/bash

# Create necessary directories for systemd services
mkdir -p "/etc/systemd/system/display-manager.target.wants"
mkdir -p "/etc/systemd/system/multi-user.target.wants"
mkdir -p "/etc/systemd/system/sockets.target.wants"
mkdir -p "/etc/systemd/system/sysinit.target.wants"

# Enable SDDM display manager
ln -sf "/usr/lib/systemd/system/sddm.service" "/etc/systemd/system/display-manager.service"
ln -sf "/usr/lib/systemd/system/sddm.service" "/etc/systemd/system/display-manager.target.wants/sddm.service"

# Enable NetworkManager
ln -sf "/usr/lib/systemd/system/NetworkManager.service" "/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service"
ln -sf "/usr/lib/systemd/system/NetworkManager.service" "/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sf "/usr/lib/systemd/system/NetworkManager-dispatcher.service" "/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service"

# Enable systemd-resolved
ln -sf "/usr/lib/systemd/system/systemd-resolved.service" "/etc/systemd/system/dbus-org.freedesktop.resolve1.service"
ln -sf "/usr/lib/systemd/system/systemd-resolved.service" "/etc/systemd/system/multi-user.target.wants/systemd-resolved.service"

# Enable systemd-timesyncd
ln -sf "/usr/lib/systemd/system/systemd-timesyncd.service" "/etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service"

# Enable systemd-networkd
ln -sf "/usr/lib/systemd/system/systemd-networkd.service" "/etc/systemd/system/dbus-org.freedesktop.network1.service"
ln -sf "/usr/lib/systemd/system/systemd-networkd.service" "/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
ln -sf "/usr/lib/systemd/system/systemd-networkd.socket" "/etc/systemd/system/sockets.target.wants/systemd-networkd.socket"

# Create directory for NetworkManager dispatcher scripts
mkdir -p "/etc/NetworkManager/dispatcher.d"

# Ensure proper permissions
chmod 755 "/etc/NetworkManager/dispatcher.d"

# Create a default network configuration
cat > "/etc/NetworkManager/conf.d/99-kalki.conf" << 'EOF'
[connection]
wifi.cloned-mac-address=stable
wifi.scan-rand-mac-address=no

[device]
wifi.backend=iwd

[main]
rc-manager=resolvconf
systemd-resolved=false
EOF

# Create a default iwd configuration
mkdir -p "/etc/iwd"
cat > "/etc/iwd/main.conf" << 'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
EnableIPv6=true
NameResolvingService=systemd
EOF

# Set correct permissions for iwd config
chmod 600 "/etc/iwd/main.conf"

# Create a default environment file for SDDM
mkdir -p "/etc/skel/.config/environment.d"
echo 'QT_QPA_PLATFORM=wayland' > "/etc/skel/.config/environment.d/99-wayland.conf"
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> "/etc/skel/.config/environment.d/99-wayland.conf"

# Create the same for the kalki user
mkdir -p "/home/kalki/.config/environment.d"
cp "/etc/skel/.config/environment.d/99-wayland.conf" "/home/kalki/.config/environment.d/"
chown -R kalki:kalki "/home/kalki/.config"
