Here’s a professional README for your `qemu-setup.sh` CLI toolkit:

---

# QEMU CLI VM Toolkit
**Description:**
A professional, interactive CLI toolkit for managing QEMU/KVM virtual machines. Supports creating disks, booting VMs from ISO, snapshots, OVA import, networking, and more — all via a simple menu or shell commands.

---

## Features

* Create and manage QCOW2 VM disks.
* Boot VMs from ISO or pre-installed disks.
* Rescue boot a VM using ISO.
* Take snapshots, list snapshots, and revert to snapshots.
* Import and boot OVA files directly.
* Interactive CLI menu for ease of use.
* Fully scriptable via CLI functions and aliases.
* Supports automated and manual VM management.
* Networking enabled by default for VMs.
* Configurable RAM and CPU cores per VM.

---

## Installation

1. Download the script:

```bash
git clone https://Github.com/LoQiseaking69/QEMU-CLI_tool.git

chmod +x ~/qemu-set.sh
```

2. Run the installer:

```bash
./qemu-set.sh
```

The script will:

* Update packages and install QEMU/KVM dependencies (`qemu-kvm`, `qemu-utils`, `virt-manager`, `libvirt`, `bridge-utils`, `tar`, `p7zip-full`, `bsdtar`).
* Verify QEMU installation.
* Create a VM directory at `~/VMs`.
* Add CLI functions and aliases to your `.bashrc`.
* Launch the interactive CLI menu.

---

## CLI Commands

| Command                                  | Description                          |
| ---------------------------------------- | ------------------------------------ |
| `newdisk <name> <sizeGB>`                | Create a new disk only               |
| `iso <vm> <iso> <sizeGB> [RAM_MB] [CPU]` | Create disk and boot ISO installer   |
| `runvm <vm> [RAM_MB] [CPU]`              | Boot installed VM                    |
| `rescuevm <vm> <iso> [RAM_MB] [CPU]`     | Boot VM with ISO attached            |
| `snap <vm> <snapname>`                   | Create snapshot                      |
| `listsnap <vm>`                          | List snapshots of VM                 |
| `revertsnap <vm> <snapname>`             | Restore snapshot                     |
| `listvms`                                | List all VM disks                    |
| `ova-run <path-to-ova>`                  | Import and boot an OVA automatically |
| `qemu-help`                              | Display help and examples            |

---

## Examples

```bash
# Create a new VM disk
newdisk testvm 15

# Boot an ISO installer
iso ubuntu-vm ubuntu-22.04.iso 20 4096 4

# Boot an existing VM
runvm ubuntu-vm 4096 4

# Rescue boot with ISO
rescuevm ubuntu-vm ubuntu.iso

# Snapshot operations
snap ubuntu-vm before-update
listsnap ubuntu-vm
revertsnap ubuntu-vm before-update

# List all VMs
listvms

# Import and boot OVA
ova-run ~/Downloads/Parrot-security.ova
```

---

## OVA Support

* Handles `.ova` extraction using `7z` or `bsdtar`.
* Converts `.vmdk` disk inside OVA to QCOW2 format for QEMU.
* Boots the imported VM automatically.

---

## Requirements

* Linux (Debian/Ubuntu recommended)
* QEMU/KVM (`qemu-system-x86_64`)
* Sufficient RAM and disk space for VMs
* Optional: `virt-manager` for GUI management

---

## Notes

* VM storage path: `~/VMs` by default.
* Default RAM: 2048 MB, default CPU cores: 2 (configurable per VM).
* Running `ova-run` may require several GB of temporary disk space.
* Networking is enabled for all VMs by default (`-net nic -net user`).

---
