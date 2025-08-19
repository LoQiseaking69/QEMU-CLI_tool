#!/usr/bin/env bash
# qemu-setup.sh
# PROFESSIONAL: Complete QEMU/KVM CLI toolkit with interactive menu, networking, snapshots, flexible VM configs, and robust OVA import

set -e

# --- Installation ---
echo "[*] Updating packages..."
sudo apt update -y

echo "[*] Installing QEMU/KVM and dependencies..."
sudo apt install -y qemu-kvm qemu-utils virt-manager libvirt-daemon-system libvirt-clients bridge-utils tar p7zip-full bsdtar

echo "[*] Verifying install..."
qemu-system-x86_64 --version || { echo "QEMU install failed"; exit 1; }

# --- VM Directory ---
VM_DIR="$HOME/VMs"
mkdir -p "$VM_DIR"

# --- VM Functions ---
newdisk() { [[ -z $1 || -z $2 ]] && { echo 'Usage: newdisk <name> <sizeGB>'; return 1; }; qemu-img create -f qcow2 "$VM_DIR/$1.img" "$2G"; echo "Disk $1.img created in $VM_DIR ($2 GB)"; }
iso() { local VM=$1 ISO=$2 SIZE=$3 RAM=${4:-2048} CPU=${5:-2}; [[ -z $VM || -z $ISO || -z $SIZE ]] && { echo 'Usage: iso <vmname> <iso> <sizeGB> [RAM_MB] [CPU_CORES]'; return 1; }; qemu-img create -f qcow2 "$VM_DIR/$VM.img" "$SIZE"G 2>/dev/null || true; qemu-system-x86_64 -enable-kvm -m $RAM -smp $CPU -hda "$VM_DIR/$VM.img" -cdrom "$ISO" -boot d -net nic -net user; }
runvm() { local VM=$1 RAM=${2:-2048} CPU=${3:-2}; [[ -z $VM ]] && { echo 'Usage: runvm <vmname> [RAM_MB] [CPU_CORES]'; return 1; }; qemu-system-x86_64 -enable-kvm -m $RAM -smp $CPU -hda "$VM_DIR/$VM.img" -boot c -net nic -net user; }
rescuevm() { local VM=$1 ISO=$2 RAM=${3:-2048} CPU=${4:-2}; [[ -z $VM || -z $ISO ]] && { echo 'Usage: rescuevm <vmname> <iso> [RAM_MB] [CPU_CORES]'; return 1; }; qemu-system-x86_64 -enable-kvm -m $RAM -smp $CPU -hda "$VM_DIR/$VM.img" -cdrom "$ISO" -boot d -net nic -net user; }
snap() { [[ -z $1 || -z $2 ]] && { echo 'Usage: snap <vmname> <snapname>'; return 1; }; qemu-img snapshot -c $2 "$VM_DIR/$1.img"; }
listsnap() { [[ -z $1 ]] && { echo 'Usage: listsnap <vmname>'; return 1; }; qemu-img snapshot -l "$VM_DIR/$1.img"; }
revertsnap() { [[ -z $1 || -z $2 ]] && { echo 'Usage: revertsnap <vmname> <snapname>'; return 1; }; qemu-img snapshot -a $2 "$VM_DIR/$1.img"; }
listvms() { ls -lh "$VM_DIR"; }

# --- OVA Importer ---
ova-run() {
    [[ -z $1 ]] && { echo 'Usage: ova-run <path-to-ova>'; return 1; }
    OVA_PATH=$1
    TMP_DIR=$(mktemp -d)
    echo "[*] Extracting $OVA_PATH to $TMP_DIR..."

    # Use 7z if available
    if command -v 7z >/dev/null 2>&1; then
        7z x "$OVA_PATH" -o"$TMP_DIR"
    else
        echo "[*] 7z not found, using bsdtar..."
        bsdtar -xf "$OVA_PATH" -C "$TMP_DIR"
    fi

    VMDK=$(find "$TMP_DIR" -type f -name '*.vmdk' | head -n1)
    [[ -z $VMDK ]] && { echo 'No VMDK found in OVA!'; return 1; }

    VM_NAME=$(basename "$OVA_PATH" .ova)
    echo "[*] Converting VMDK to QCOW2 at $VM_DIR/$VM_NAME.img..."
    qemu-img convert -f vmdk "$VMDK" -O qcow2 "$VM_DIR/$VM_NAME.img"

    echo "[*] Cleaning temporary files..."
    rm -rf "$TMP_DIR"

    echo "[*] Booting $VM_NAME..."
    runvm "$VM_NAME"
}

# --- Help ---
qemu-help() {
    echo ""
    echo "QEMU CLI Toolkit Help"
    echo "------------------------------"
    echo "newdisk <name> <sizeGB>                   - Create a new disk only"
    echo "iso <vm> <iso> <sizeGB> [RAM_MB] [CPU]  - Create disk + boot ISO installer"
    echo "runvm <vm> [RAM_MB] [CPU]                - Boot installed VM"
    echo "rescuevm <vm> <iso> [RAM_MB] [CPU]      - Boot VM with ISO attached"
    echo "snap <vm> <snapname>                     - Create snapshot"
    echo "listsnap <vm>                            - List snapshots of VM"
    echo "revertsnap <vm> <snapname>               - Restore snapshot"
    echo "listvms                                  - List all VM disks"
    echo "ova-run <path-to-ova>                     - Import and boot an OVA automatically"
    echo ""
    echo "Examples:"
    echo "  newdisk testvm 15"
    echo "  iso ubuntu-vm ubuntu-22.04.iso 20 4096 4"
    echo "  runvm ubuntu-vm 4096 4"
    echo "  rescuevm ubuntu-vm ubuntu.iso"
    echo "  snap ubuntu-vm before-update"
    echo "  listsnap ubuntu-vm"
    echo "  revertsnap ubuntu-vm before-update"
    echo "  listvms"
    echo "  ova-run ~/Downloads/Parrot-security.ova"
    echo ""
}

# --- Interactive CLI menu ---
while true; do
    clear
    echo "====================================="
    echo "        QEMU CLI VM TOOLKIT          "
    echo "====================================="
    echo "1) List VM disks"
    echo "2) Create new disk"
    echo "3) Boot VM from ISO"
    echo "4) Boot installed VM"
    echo "5) Rescue VM with ISO"
    echo "6) Create snapshot"
    echo "7) List snapshots"
    echo "8) Revert snapshot"
    echo "9) Import and boot OVA"
    echo "10) Help"
    echo "0) Exit"
    echo "-------------------------------------"
    read -p "Select an option [0-10]: " choice
    case $choice in
        1) listvms; read -p "Press Enter to continue...";;
        2) read -p "VM name: " vm; read -p "Disk size (GB): " size; newdisk "$vm" "$size"; read -p "Press Enter...";;
        3) read -p "VM name: " vm; read -p "ISO path: " iso; read -p "Disk size (GB): " size; read -p "RAM (MB, default 2048): " ram; read -p "CPU cores (default 2): " cpu; iso "$vm" "$iso" "$size" "${ram:-2048}" "${cpu:-2}"; read -p "Press Enter...";;
        4) read -p "VM name: " vm; read -p "RAM (MB, default 2048): " ram; read -p "CPU cores (default 2): " cpu; runvm "$vm" "${ram:-2048}" "${cpu:-2}"; read -p "Press Enter...";;
        5) read -p "VM name: " vm; read -p "ISO path: " iso; read -p "RAM (MB, default 2048): " ram; read -p "CPU cores (default 2): " cpu; rescuevm "$vm" "$iso" "${ram:-2048}" "${cpu:-2}"; read -p "Press Enter...";;
        6) read -p "VM name: " vm; read -p "Snapshot name: " snap; snap "$vm" "$snap"; read -p "Press Enter...";;
        7) read -p "VM name: " vm; listsnap "$vm"; read -p "Press Enter...";;
        8) read -p "VM name: " vm; read -p "Snapshot name: " snap; revertsnap "$vm" "$snap"; read -p "Press Enter...";;
        9) read -p "OVA file path: " ova; ova-run "$ova"; read -p "Press Enter...";;
        10) qemu-help; read -p "Press Enter...";;
        0) echo "Exiting QEMU CLI Toolkit."; break;;
        *) echo "Invalid option!"; read -p "Press Enter...";;
    esac
done
