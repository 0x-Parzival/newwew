# Kalki OS Live Environment Management

This document provides instructions for managing the live environment, particularly focusing on handling space constraints during installation and system operations.

## Managing Cowspace in Live Environment

The live environment uses a Copy-On-Write (COW) filesystem that may run into space limitations. Here's how to manage it:

### Checking Current Cowspace Status

```bash
sudo /usr/local/bin/manage-cowspace
```

This will display the current usage and available space in the cowspace.

### Increasing Cowspace Size

To increase the cowspace size (recommended: 4-8GB):

```bash
sudo /usr/local/bin/manage-cowspace -s 4
```

Replace `4` with the desired size in gigabytes.

### Automatic Cowspace Management (Recommended)

1. **During First Boot**:
   - The system will automatically attempt to allocate 4GB of cowspace
   - If successful, you'll see a confirmation message
   - If it fails, you'll be prompted to resize manually

2. **For Large Installations**:
   - If you're installing many packages, consider increasing cowspace before starting:
     ```bash
     sudo /usr/local/bin/manage-cowspace -s 8
     ```

## Common Issues and Solutions

### "No space left on device" Error

If you encounter this error:

1. Check current space:
   ```bash
   df -h /run/archiso/cowspace
   ```

2. Increase cowspace:
   ```bash
   sudo /usr/local/bin/manage-cowspace -s 6
   ```

3. If that fails, try remounting:
   ```bash
   sudo umount /run/archiso/cowspace
   sudo mount -t tmpfs -o size=6G cowspace /run/archiso/cowspace
   ```

### Persistent Storage

For persistent storage across reboots:

1. Create a persistent storage file:
   ```bash
   fallocate -l 4G /mnt/persistent.img
   mkfs.ext4 /mnt/persistent.img
   ```

2. Mount it:
   ```bash
   mkdir -p /mnt/persistent
   mount -o loop /mnt/persistent.img /mnt/persistent
   ```

3. Bind mount to cowspace:
   ```bash
   mount --bind /mnt/persistent /run/archiso/cowspace
   ```

## Post-Installation

After installation, these space constraints won't apply as the system will use the full disk space allocated during installation.

For best performance, ensure your system has at least 8GB of RAM when running the live environment with large cowspace allocations.
