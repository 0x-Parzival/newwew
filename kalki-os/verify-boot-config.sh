#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
ISO_PROFILE="/home/xero/os/kalki-os/iso-profile/kalki-base"
PROFILE_DEF="$ISO_PROFILE/profiledef.sh"
SYSLINUX_CFG="$ISO_PROFILE/syslinux/syslinux.cfg"
EFI_ENTRY="$ISO_PROFILE/efiboot/loader/entries/01-archiso-x86_64-linux.conf"

# Function to print status messages
print_status() {
    local color=$1
    local message=$2
    local status=$3
    printf "%-60s [${color}%s${NC}]\n" "$message" "$status"
}

# Function to check if a file exists
check_file_exists() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        print_status "$GREEN" "$desc" "FOUND"
        return 0
    else
        print_status "$RED" "$desc" "MISSING"
        return 1
    fi
}

# Function to check if a string is in a file
check_contains() {
    local file=$1
    local search=$2
    local desc=$3
    if grep -q "$search" "$file" 2>/dev/null; then
        print_status "$GREEN" "$desc" "FOUND"
        return 0
    else
        print_status "$RED" "$desc" "MISSING"
        return 1
    fi
}

# Main verification function
verify_boot_config() {
    echo -e "${YELLOW}=== Verifying Boot Configuration ===${NC}"
    
    # 1. Check if required files exist
    echo -e "${YELLOW}Checking required files:${NC}"
    check_file_exists "$PROFILE_DEF" "Profile definition file"
    check_file_exists "$SYSLINUX_CFG" "SYSLINUX configuration"
    check_file_exists "$EFI_ENTRY" "UEFI boot entry"
    
    # 2. Verify ISO label in profiledef.sh
    echo -e "\n${YELLOW}Verifying ISO label configuration:${NC}"
    ISO_LABEL=$(grep '^iso_label=' "$PROFILE_DEF" | cut -d'"' -f2)
    if [ -n "$ISO_LABEL" ]; then
        print_status "$GREEN" "ISO Label" "$ISO_LABEL"
        
        # Check if label is in the correct format (uppercase, no spaces, max 11 chars for ISO9660)
        if [[ "$ISO_LABEL" =~ ^[A-Z0-9_]{1,11}$ ]]; then
            print_status "$GREEN" "ISO Label format" "VALID"
        else
            print_status "$RED" "ISO Label format" "INVALID (must be uppercase, no spaces, max 11 chars)"
        fi
    else
        print_status "$RED" "ISO Label" "NOT FOUND"
    fi
    
    # 3. Verify bootmodes in profiledef.sh
    echo -e "\n${YELLOW}Verifying boot modes:${NC}"
    BOOTMODES=$(grep '^bootmodes=' "$PROFILE_DEF" | cut -d'=' -f2- | tr -d "'" | tr -d '()')
    if [ -n "$BOOTMODES" ]; then
        print_status "$GREEN" "Boot Modes" "$BOOTMODES"
        
        # Check for required boot modes
        if [[ "$BOOTMODES" == *"bios.syslinux.mbr"* ]]; then
            print_status "$GREEN" "  - BIOS (SYSLINUX)" "ENABLED"
        else
            print_status "$YELLOW" "  - BIOS (SYSLINUX)" "DISABLED"
        fi
        
        if [[ "$BOOTMODES" == *"uefi"* ]]; then
            print_status "$GREEN" "  - UEFI (systemd-boot)" "ENABLED"
        else
            print_status "$YELLOW" "  - UEFI (systemd-boot)" "DISABLED"
        fi
    else
        print_status "$RED" "Boot Modes" "NOT CONFIGURED"
    fi
    
    # 4. Check kernel and initramfs paths in UEFI config
    echo -e "\n${YELLOW}Verifying UEFI boot configuration:${NC}"
    if [ -f "$EFI_ENTRY" ]; then
        KERNEL_PATH=$(grep '^linux' "$EFI_ENTRY" | awk '{print $2}')
        INITRD_PATH=$(grep '^initrd' "$EFI_ENTRY" | awk '{print $2}')
        
        # Replace %INSTALL_DIR% with actual install dir
        INSTALL_DIR=$(grep '^install_dir=' "$PROFILE_DEF" | cut -d'"' -f2)
        KERNEL_PATH=${KERNEL_PATH/\%INSTALL_DIR\%/$INSTALL_DIR}
        INITRD_PATH=${INITRD_PATH/\%INSTALL_DIR\%/$INSTALL_DIR}
        
        # Check if kernel exists
        if [ -f "$ISO_PROFILE/airootfs/$KERNEL_PATH" ]; then
            print_status "$GREEN" "Kernel path" "$KERNEL_PATH (FOUND)"
        else
            print_status "$RED" "Kernel path" "$KERNEL_PATH (MISSING)"
        fi
        
        # Check if initramfs exists
        if [ -f "$ISO_PROFILE/airootfs/$INITRD_PATH" ]; then
            print_status "$GREEN" "Initramfs path" "$INITRD_PATH (FOUND)"
        else
            print_status "$RED" "Initramfs path" "$INITRD_PATH (MISSING)"
        fi
        
        # Check for required kernel parameters
        KERNEL_OPTS=$(grep '^options' "$EFI_ENTRY")
        if [[ "$KERNEL_OPTS" == *"archisobasedir"* ]]; then
            print_status "$GREEN" "Kernel options" "Contains archisobasedir"
        else
            print_status "$RED" "Kernel options" "Missing archisobasedir"
        fi
    fi
    
    # 5. Check for required boot files
    echo -e "\n${YELLOW}Verifying required boot files:${NC}"
    
    # Check for ISOLINUX files
    if [ -d "$ISO_PROFILE/syslinux" ]; then
        check_file_exists "$ISO_PROFILE/syslinux/whichsys.c32" "SYSLINUX whichsys.c32"
        check_file_exists "$ISO_PROFILE/syslinux/archiso_sys.cfg" "SYSLINUX archiso_sys.cfg"
        check_file_exists "$ISO_PROFILE/syslinux/archiso_pxe.cfg" "SYSLINUX archiso_pxe.cfg"
    fi
    
    # Check for UEFI files
    if [ -d "$ISO_PROFILE/efiboot" ]; then
        check_file_exists "$ISO_PROFILE/efiboot/EFI/BOOT/BOOTX64.EFI" "UEFI Bootloader"
        check_file_exists "$ISO_PROFILE/efiboot/loader/loader.conf" "systemd-boot config"
    fi
    
    echo -e "\n${YELLOW}=== Boot Configuration Check Complete ===${NC}"
}

# Run the verification
verify_boot_config
