# 5 · BusyBox Root Filesystem

> Build a minimal root filesystem with BusyBox and boot it three ways: over NFS, from the SD card, and as an initramfs.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1.5 hours |
| **Previous** | [4 · Linux kernel](../04-kernel/README.md) |
| **Next** | [6 · Init process](../06-init/README.md) |

## What you will learn

- What a root filesystem must contain for the kernel to finish booting
- How to build BusyBox statically and install it into a rootfs folder
- How `init`, `/etc/inittab` and `/etc/init.d/rcS` start the system
- Three ways to give the kernel its root filesystem: **NFS**, **SD card**, **initramfs**

## Prerequisites

- [Lesson 4](../04-kernel/README.md) done: the kernel boots and panics with `Unable to mount root fs`
- `CROSS_COMPILE` and `ARCH` exported
- The kernel modules from lesson 4 installed in `$HOME/rootfs`

## Background

After it starts, the kernel mounts the root filesystem and runs **`/sbin/init`** as PID 1. A minimal rootfs needs:

| Path | Why |
|---|---|
| `/bin`, `/sbin`, `/usr` | Programs: shell, `init`, `mount`, `ls`... |
| `/dev` | Device nodes (filled by the kernel thanks to `devtmpfs`) |
| `/proc`, `/sys` | Mount points for the kernel's virtual filesystems |
| `/etc/inittab`, `/etc/init.d/rcS` | What `init` should do at boot |
| `/lib` | Shared libraries (empty if everything is static) and kernel modules |

**BusyBox** provides hundreds of Unix commands (`sh`, `ls`, `mount`, `init`...) in **one small binary**; each command
is a symbolic link to it. Building it **statically** means it needs no `.so` files in `/lib` (remember
[lesson 1](../01-libraries/README.md)).

Where does the kernel find this filesystem? That's what the `root=` argument in `bootargs` decides:

<figure class="el-anim">
<img src="rootfs-options.svg" alt="The kernel can mount its root filesystem over NFS from the PC, from the SD card's second partition, or from an initramfs loaded into RAM; then it runs /sbin/init">
<ol class="el-anim-steps">
<li>The kernel has started, but it needs a root filesystem. The <code>root=</code> argument in <code>bootargs</code> tells it where to look.</li>
<li><b>NFS</b>: the rootfs is a folder on your PC, shared over the network. Change a file on the PC and it's instantly on the board. Ideal while developing.</li>
<li><b>SD card</b>: the rootfs is copied into partition 2. The board boots on its own, like a real product.</li>
<li><b>initramfs</b>: the rootfs is packed into an archive that U-Boot loads into RAM next to the kernel. Used for early boot tasks, or as the only rootfs on very small systems.</li>
<li>Whichever you choose, the kernel then runs <code>/sbin/init</code> as PID 1. Lesson 6 looks at what init does.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/05-rootfs/index.html">course website</a>.</figcaption>
</figure>

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

`init` reads this file first.

```bash title="$HOME/rootfs/etc/inittab"
# run the startup script once at boot
::sysinit:/etc/init.d/rcS
# start a shell on the console, after "Please press Enter"
::askfirst:-/bin/sh
# what to do when init is restarted
::restart:/sbin/init
```

An empty first field means "the console the kernel was given with `console=`", so this works on every board.

### 6. Create the startup script `/etc/init.d/rcS`

```sh title="$HOME/rootfs/etc/init.d/rcS"
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

Pick one of the three methods. In every case the kernel and device tree come from TFTP as in lesson 4; only
`bootargs` (and, for initramfs, one extra file) change. Use your board's console from
[lesson 4](../04-kernel/README.md#7-boot-the-kernel-from-u-boot): `ttyAMA0` for QEMU, `ttyS0,115200` for the Pi and BeagleBone.

#### Option A · Root filesystem over NFS (best while developing)

```bash
sudo apt install nfs-kernel-server

# share the folder with the board's IP address
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

#### Option B · Root filesystem on the SD card

Copy the rootfs into the second (ext4) partition created in [lesson 3](../03-u-boot/README.md#5-prepare-the-sd-card):

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

#### Option C · initramfs (rootfs in RAM)

An **initramfs** is a compressed `cpio` archive. The kernel needs `CONFIG_BLK_DEV_INITRD=y`.

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

> [!TIP]
> **Built-in initramfs:** if your bootloader can't load a separate ramdisk, set `CONFIG_INITRAMFS_SOURCE`
> (General setup → Initramfs source file(s)) to the full path of the **uncompressed** `initramfs.cpio` and
> rebuild the kernel. The archive is then embedded in `zImage`.

## Checkpoint

With Option A or B you should end with:

```text
Run /sbin/init as init process
...
Please press Enter to activate this console.
/ #
```

Then try `ls /proc`, `uname -a` and `ps`. With Option C you get the `/ #` prompt straight away (no `init`:
the kernel runs `/bin/sh` directly).

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `can't run '/etc/init.d/rcS': Permission denied` | Script not executable | `sudo chmod +x $HOME/rootfs/etc/init.d/rcS` |
| `VFS: Unable to mount root fs via NFS` | Export missing, wrong path, or wrong IPs | `sudo exportfs -v` on the host; check `nfsroot=` and `ip=` |
| `Kernel panic ... No working init found` | BusyBox missing, or built for the wrong CPU | `file $HOME/rootfs/bin/busybox` must say ARM and *statically linked* |
| `/bin/sh: can't access tty; job control turned off` | Shell started without a real tty (initramfs, `rdinit=/bin/sh`) | Harmless here |
| Build error in `networking/tc.c` (`TCA_CBQ_...` undeclared) | Toolchain kernel headers ≥ 6.8 removed CBQ | menuconfig → Networking Utilities → disable `tc` |
| SD boot waits forever | `rootwait` with the wrong partition | `root=/dev/mmcblk0p2` must be the ext4 partition |

## Exercises

1. Boot over NFS, then create a file in `$HOME/rootfs/tmp` on the host and `ls /tmp` on the board.
2. Add an `echo` welcome banner to `rcS` and reboot.
3. Change Option C to `rdinit=/sbin/init` so the initramfs uses your `inittab`.

## Recap

- You built a working Linux system by hand: U-Boot + kernel + BusyBox rootfs.
- Next you'll look closer at **PID 1**, and use it to start your own daemon at boot.
