# 5 - BusyBox Root Filesystem

> Build a minimal root filesystem with BusyBox and boot it three ways: over NFS, from the SD card, and as an initramfs.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1.5 hours |
| **Previous** | [4 - Linux kernel](../4-kernel/README.md) |
| **Next** | [6 - Init process](../6-InitProcess/README.md) |

## What you will learn

- What a root filesystem must contain for the kernel to finish booting
- How to build BusyBox statically and install it into a rootfs folder
- How `init`, `/etc/inittab` and `/etc/init.d/rcS` start the system
- Three ways to give the kernel its rootfs: **NFS**, **SD card**, **initramfs**

## Prerequisites

- [Lesson 4](../4-kernel/README.md) done: the kernel boots and panics with `Unable to mount root fs`
- `CROSS_COMPILE` and `ARCH` exported
- The modules from lesson 4 installed in `$HOME/rootfs`

## Background

After the kernel starts, it mounts the root filesystem and runs **`/sbin/init`** as PID 1. A minimal rootfs needs:

| Path | Why |
|---|---|
| `/bin`, `/sbin`, `/usr` | Programs: shell, `init`, `mount`, `ls`... |
| `/dev` | Device nodes (filled by the kernel thanks to `devtmpfs`) |
| `/proc`, `/sys` | Mount points for the kernel's virtual filesystems |
| `/etc/inittab`, `/etc/init.d/rcS` | What `init` should do at boot |
| `/lib` | Shared libraries (empty if everything is static) and kernel modules |

**BusyBox** provides hundreds of Unix commands (`sh`, `ls`, `mount`, `init`...) in **one small binary**;
each command is a symbolic link to it. Building it **statically** means it doesn't need any `.so`
in `/lib` (remember [lesson 1](../1-Library/README.md)).

## Steps

### 1. Download BusyBox

```bash
git clone https://github.com/mirror/busybox.git
cd busybox/
git checkout 1_36_1
```

### 2. Configure

```bash
make defconfig
make menuconfig
```

| Requirement | Where in menuconfig | Symbol |
|---|---|---|
| Static binary | Settings → Build static binary (no shared libs) | `STATIC=y` |

### 3. Build and install into the rootfs folder

```bash
make -j$(nproc)

# installs bin/, sbin/, usr/ and linuxrc into $HOME/rootfs
make CONFIG_PREFIX=$HOME/rootfs install
```

### 4. Create the rest of the rootfs

```bash
cd $HOME/rootfs
mkdir -p dev etc/init.d proc sys tmp
```

### 5. Create `/etc/inittab`

`init` reads this file first. Create `$HOME/rootfs/etc/inittab`:

```bash
# run the startup script once at boot
::sysinit:/etc/init.d/rcS
# start a shell on the console, after "Please press Enter"
::askfirst:-/bin/sh
# what to do when init is restarted
::restart:/sbin/init
```

An empty first field means "the console the kernel was given with `console=`", so this works on every board.

### 6. Create the startup script `/etc/init.d/rcS`

```sh
#!/bin/sh
# mount the kernel's virtual filesystems
mount -t proc nodev /proc
mount -t sysfs nodev /sys
# if devtmpfs is not enabled in the kernel, populate /dev yourself:
# mdev -s
```

```bash
chmod +x $HOME/rootfs/etc/init.d/rcS

# files on the target should belong to root
sudo chown -R root:root $HOME/rootfs
```

### 7. Boot the rootfs

Pick one of the three methods. In every case the kernel and dtb are loaded from TFTP as in lesson 4;
only `bootargs` (and, for initramfs, one extra file) change.

Use your board's console from [lesson 4](../4-kernel/README.md#7-boot-the-kernel-from-u-boot)
(`ttyAMA0` for QEMU, `ttyS0,115200` for Pi and BeagleBone).

#### Option A - Root filesystem over NFS (best while developing)

The board mounts `$HOME/rootfs` straight from your PC: edit a file on the host, and it's instantly on the target.

```bash
sudo apt install nfs-kernel-server

# export the folder to the board's IP
echo "$HOME/rootfs 192.168.0.100(rw,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -r
```

```bash
# U-Boot prompt
setenv bootargs console=ttyAMA0 root=/dev/nfs ip=192.168.0.100:::::eth0 nfsroot=192.168.0.1:/home/<you>/rootfs,nfsvers=3,tcp rw init=/sbin/init
tftp ${kernel_addr_r} zImage
tftp ${fdt_addr_r} <your-board>.dtb
bootz ${kernel_addr_r} - ${fdt_addr_r}
```

#### Option B - Root filesystem on the SD card

Copy the rootfs into the second (ext4) partition created in [lesson 3](../3-Uboot/README.md#5-prepare-the-sd-card):

```bash
# DISK is your SD card or loop device from lesson 3
sudo mkdir -p /mnt/rootfs
sudo mount ${DISK}p2 /mnt/rootfs        # /dev/sdX2 on a USB card reader
sudo cp -a $HOME/rootfs/* /mnt/rootfs/
sudo umount /mnt/rootfs
```

```bash
# U-Boot prompt
setenv bootargs console=ttyAMA0 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait init=/sbin/init
tftp ${kernel_addr_r} zImage
tftp ${fdt_addr_r} <your-board>.dtb
bootz ${kernel_addr_r} - ${fdt_addr_r}
```

#### Option C - initramfs (rootfs in RAM)

An **initramfs** is a compressed `cpio` archive that the bootloader loads into RAM next to the kernel. It's
used for early boot tasks (loading drivers, unlocking disks) before switching to the real rootfs, or as
the only rootfs on very small systems. The kernel needs `CONFIG_BLK_DEV_INITRD=y`.

```bash
cd $HOME/rootfs
# pack everything except kernel modules (they take a lot of space)
find . -path ./lib/modules -prune -o -print | cpio -H newc -ov --owner root:root > ../initramfs.cpio
cd ..
gzip initramfs.cpio

# wrap it with a U-Boot header (mkimage comes from u-boot-tools)
mkimage -A arm -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
cp uRamdisk /srv/tftp/        # or copy it to the SD card's FAT partition
```

```bash
# U-Boot prompt
setenv bootargs console=ttyAMA0 rdinit=/bin/sh
tftp ${kernel_addr_r} zImage
tftp ${fdt_addr_r} <your-board>.dtb
tftp ${ramdisk_addr_r} uRamdisk          # or: fatload mmc 0:1 ${ramdisk_addr_r} uRamdisk
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
```

> **Built-in initramfs:** if your bootloader can't load a separate ramdisk, set
> `CONFIG_INITRAMFS_SOURCE` (General setup → Initramfs source file(s)) to the full path of the
> **uncompressed** `initramfs.cpio` and rebuild the kernel. It's then embedded in `zImage`.

## Checkpoint

With Option A or B you should end with:

```text
Run /sbin/init as init process
...
Please press Enter to activate this console.
/ #
```

Then try `ls /proc`, `uname -a` and `ps`. With Option C you get the `/ #` prompt directly
(no `init`, the kernel runs `/bin/sh`).

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `can't run '/etc/init.d/rcS': Permission denied` | Script not executable | `chmod +x $HOME/rootfs/etc/init.d/rcS` |
| `VFS: Unable to mount root fs via NFS` | Export missing, wrong path, or IPs wrong | `sudo exportfs -v` on the host; check `nfsroot=` path and `ip=` |
| `Kernel panic ... No working init found` | BusyBox not installed or built for the wrong CPU | Check `file $HOME/rootfs/bin/busybox` says ARM and *statically linked* |
| `/bin/sh: can't access tty; job control turned off` | Shell started without a real tty (initramfs `rdinit=/bin/sh`) | Harmless for this exercise |
| Build error in `networking/tc.c` (`TCA_CBQ_...` undeclared) | Toolchain uses kernel headers ≥ 6.8 where CBQ was removed | In menuconfig, Networking Utilities → disable `tc` |
| SD boot waits forever | `rootwait` and wrong partition | Check `root=/dev/mmcblk0p2` matches the ext4 partition |

## Exercises

1. Boot with NFS, then create a file in `$HOME/rootfs/tmp` on the host and `ls /tmp` on the target.
2. Add a line to `rcS` that prints a welcome banner with `echo`, and reboot.
3. Change Option C to `rdinit=/sbin/init` so the initramfs uses your `inittab`.

## Recap

- You built a working Linux system by hand: U-Boot + kernel + BusyBox rootfs.
- Next you will look closer at **PID 1**, and how BusyBox init, System V init and systemd start your own applications.
