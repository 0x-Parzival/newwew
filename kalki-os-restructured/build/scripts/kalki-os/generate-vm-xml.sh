#!/bin/bash
# generate-vm-xml.sh: Generate a customized kalki-vm.xml for your environment and optionally launch the VM
#
# Usage:
#   ./generate-vm-xml.sh [--iso /path/to/kalki.iso] [--disk /path/to/disk.img] [--ram 8] [--cpus 4] [--output kalki-vm.xml] [--launch]
#
# If not specified, prompts for each value. Defaults:
#   --iso: latest kalki-*.iso in ../out/
#   --disk: /var/lib/libvirt/images/kalki-vm.qcow2
#   --ram: 8 (GiB)
#   --cpus: 4
#   --output: kalki-vm.xml
#   --launch: define and start the VM after generating XML

set -euo pipefail

ISO_PATH=""
DISK_PATH="/var/lib/libvirt/images/kalki-vm.qcow2"
RAM=8
CPUS=4
OUTPUT="kalki-vm.xml"
LAUNCH=false

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --iso) ISO_PATH="$2"; shift 2;;
    --disk) DISK_PATH="$2"; shift 2;;
    --ram) RAM="$2"; shift 2;;
    --cpus) CPUS="$2"; shift 2;;
    --output) OUTPUT="$2"; shift 2;;
    --launch) LAUNCH=true; shift;;
    --help|-h)
      grep '^#' "$0" | cut -c 3-
      exit 0;;
    *) echo "Unknown argument: $1"; exit 1;;
  esac
done

# Find latest ISO if not specified
if [ -z "$ISO_PATH" ]; then
  ISO_PATH=$(find ../out -name "kalki-*.iso" -type f | sort -r | head -n 1 || true)
  if [ -z "$ISO_PATH" ]; then
    read -rp "Enter path to Kalki OS ISO: " ISO_PATH
  fi
fi

read -rp "ISO path [$ISO_PATH]: " input; ISO_PATH="${input:-$ISO_PATH}"
read -rp "Disk image path [$DISK_PATH]: " input; DISK_PATH="${input:-$DISK_PATH}"
read -rp "RAM in GiB [$RAM]: " input; RAM="${input:-$RAM}"
read -rp "CPU cores [$CPUS]: " input; CPUS="${input:-$CPUS}"
read -rp "Output XML file [$OUTPUT]: " input; OUTPUT="${input:-$OUTPUT}"

cat > "$OUTPUT" <<EOF
<domain type='kvm'>
  <name>kalki-vm</name>
  <memory unit='GiB'>$RAM</memory>
  <currentMemory unit='GiB'>$RAM</currentMemory>
  <vcpu placement='static'>$CPUS</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-7.2'>hvm</type>
    <boot dev='cdrom'/>
    <boot dev='hd'/>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <vmport state='off'/>
  </features>
  <cpu mode='host-passthrough' check='none' migratable='on'/>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='$ISO_PATH'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <boot order='1'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='$DISK_PATH'/>
      <target dev='vda' bus='virtio'/>
      <boot order='2'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
    </controller>
    <controller type='sata' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='pci' index='1' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='1' port='0x10'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
    </controller>
    <controller type='pci' index='2' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='2' port='0x11'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
    </controller>
    <controller type='pci' index='3' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='3' port='0x12'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
    </controller>
    <controller type='pci' index='4' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='4' port='0x13'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:11:22:33'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice' autoport='yes'>
      <listen type='address'/>
      <image compression='off'/>
    </graphics>
    <sound model='ich9'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1b' function='0x0'/>
    </sound>
    <video>
      <model type='virtio' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
    </memballoon>
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
      <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
    </rng>
  </devices>
</domain>
EOF

echo "VM XML generated at $OUTPUT"

if [ "$LAUNCH" = true ]; then
  echo "Defining and starting VM via virsh..."
  if ! command -v virsh >/dev/null 2>&1; then
    echo "virsh not found. Please install libvirt-clients or run manually: virsh define $OUTPUT && virsh start kalki-vm"; exit 1
  fi
  virsh destroy kalki-vm 2>/dev/null || true
  virsh undefine kalki-vm 2>/dev/null || true
  virsh define "$OUTPUT"
  virsh start kalki-vm
  echo "VM 'kalki-vm' started. Connect with virt-manager or:"
  echo "  virsh console kalki-vm"
fi 