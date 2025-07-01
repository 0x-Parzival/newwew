#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display section headers
section() {
    echo -e "\n${YELLOW}==> ${1}${NC}"
}

# Function to display success messages
success() {
    echo -e "${GREEN}[✓] ${1}${NC}"
}

# Function to display error messages
error() {
    echo -e "${RED}[✗] ${1}${NC}" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root. Please use 'sudo'."
fi

# Update system and install required packages
section "Installing required packages..."
pacman -Syu --noconfirm --needed \
    qemu-full \
    libvirt \
    virt-manager \
    ebtables \
    dnsmasq \
    bridge-utils \
    virt-viewer \
    spice-vdagent \
    libguestfs \
    ovmf \
    swtpm \
    edk2-ovmf

# Enable and start libvirtd
section "Enabling libvirtd service..."
systemctl enable --now libvirtd

# Add user to necessary groups
section "Configuring user permissions..."
usermod -aG libvirt,kvm,input $(logname)

# Configure libvirt
section "Configuring libvirt..."
cat > /etc/libvirt/qemu.conf << 'EOL'
user = "root"
group = "root"
security_driver = "none"
dynamic_ownership = 0
remember_owner = 0
cgroup_controllers = [ ]
EOL

# Create storage pool if it doesn't exist
if ! virsh pool-list --all | grep -q default; then
    section "Creating default storage pool..."
    virsh pool-define /dev/stdin << 'EOL'
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOL
    virsh pool-autostart default
    virsh pool-start default
fi

# Create VM disk image
VM_DISK="/var/lib/libvirt/images/kalki-vm.qcow2"
if [ ! -f "$VM_DISK" ]; then
    section "Creating VM disk image..."
    qemu-img create -f qcow2 "$VM_DISK" 40G
    chown $(logname):kvm "$VM_DISK"
    chmod 660 "$VM_DISK"
fi

# Copy VM configuration
section "Setting up VM configuration..."
cp kalki-vm.xml /etc/libvirt/qemu/
chown root:root /etc/libvirt/qemu/kalki-vm.xml
chmod 644 /etc/libvirt/qemu/kalki-vm.xml

# Install systemd service
section "Installing systemd service..."
cp kalki-vm.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable kalki-vm.service

# Configure network
section "Configuring network..."
cat > /etc/libvirt/qemu/networks/default.xml << 'EOL'
<network>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOL

# Define and start the network
if ! virsh net-list --all | grep -q default; then
    virsh net-define /etc/libvirt/qemu/networks/default.xml
    virsh net-autostart default
    virsh net-start default
fi

# Set up permissions
section "Setting up permissions..."
cat > /etc/polkit-1/rules.d/80-libvirt-manage.rules << 'EOL'
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" && 
        subject.isInGroup("libvirt")) {
        return polkit.Result.YES;
    }
});
EOL

# Restart services
section "Restarting services..."
systemctl restart libvirtd

success "VM environment setup completed successfully!"
echo -e "\n${YELLOW}Next steps:\n1. Log out and back in for group changes to take effect\n2. Build the ISO with './build-ai-integrated-kalki.sh'\n3. Start the VM with 'systemctl start kalki-vm' or using virt-manager\n${NC}"
