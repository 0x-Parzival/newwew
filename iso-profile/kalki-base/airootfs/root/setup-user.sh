#!/bin/bash

# Create the kalki user with appropriate settings
username="kalki"
uid=1000
home_dir="/home/$username"

# Create user directories
mkdir -p "$home_dir"
chmod 700 "$home_dir"
chown $uid:$uid "$home_dir"

# Add user to /etc/passwd
echo "$username:x:$uid:$uid::/home/$username:/bin/zsh" >> /etc/passwd

# Add user to /etc/shadow (passwordless login - set to ! to lock the password)
echo "$username:!:::::::" >> /etc/shadow

# Add user to /etc/group (create primary group)
echo "$username:x:$uid:" >> /etc/group

# Add user to /etc/gshadow (empty password hash)
echo "$username:!::" >> /etc/gshadow

# Add user to additional groups for hardware access
for group in wheel video audio optical storage power network input users uucp rfkill scanner lp sys tty disk; do
    if grep -q "^$group:" /etc/group; then
        gpasswd -a "$username" "$group" 2>/dev/null || true
    fi
done

# Set up skeleton files
cp -rT /etc/skel/ "$home_dir/"
chown -R $uid:$uid "$home_dir"

# Set default permissions
chmod 755 /home
chmod 700 "$home_dir"

# Configure sudoers
mkdir -p /etc/sudoers.d
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-kalki
chmod 440 /etc/sudoers.d/10-kalki

# Create necessary directories in user's home
mkdir -p "$home_dir/.config" "$home_dir/.local/share" "$home_dir/.cache"
chown -R $uid:$uid "$home_dir"
