# BusyBox

**BusyBox** is a software suite that provides a single binary executable file that contains many common Unix utilities. It is designed to be **small and efficient**, and is often used in **embedded systems** or other systems with limited resources. 

## Download BusyBox

```bash
git clone https://github.com/mirror/busybox.git
cd busybox/
```

## Configure BusyBox

```bash
make menuconfig
```

## Compile BusyBox

```bash
# export the compiler on the system
# chose the right compiler that corespond to your board
export CROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-
export ARCH=arm

# Configure busybox to be static build from menuconfig
make menuconfig

#build the busybox to get the minimal command
make

# generate the rootfs
make install
# this will create folder name _install has all binary
```

## Create the Rootfs

We need to copy the rootfs under folder `_install` under file name backwards of BusyBox directory  

```bash
# to go out from busybox directory
cd ..

# create directory rootfs
mkdir rootfs

# copy the content inside the _install into rootfs
cp -rp ./busybox/_install/ ./rootfs

# change directory to rootfs
cd rootfs

# create the rest folder for rootfs
mkdir -p ./dev /etc

#create folder inittab
touch /etc/inittab
```

#### Configure Inittab

We need to setup **inittab** file because it's the first thing that the **init** process look at

```bash
# inittab file 
::sysinit:/etc/init.d/rcS
# Start an "askfirst" shell on the console (whatever that may be)
ttyAMA0::askfirst:-/bin/sh
# Stuff to do when restarting the init process
::restart:/sbin/init
```

# Mount rootfs Through NFS

## Install NFS

```bash
# Install an NFS server
sudo apt install nfs-kernel-server

# Add exported directory to `/etc/exports` file, with target ip as follows
/PathToDirectory/rootfs 192.168.0.100(rw,no_root_squash,no_subtree_check)

# Ask NFS server to apply this new configuration (reload this file)
sudo exportfs -r
```

## Setup Bootargs in U-Boot

```bash
setenv bootargs console=ttyXXX root=/dev/nfs ip=192.168.0.100:::::eth0 nfsroot=192.168.0.1:/home/fady/Documents/busybox/_install,nfsvers=3,tcp rw init=/sbin/init

# make sure the console tty represet the machine you working on
```

# Mount rootfs through SD Card

```bash
# mount the sd card to the host file system
# No need to do this command if the sd card already mounted
sudo mount /dev/mmblck<x> /media/SDCARD

# copy rootfs into the sd card
cd rootfs
cp -r * /media/SDCARD/rootfs

# unmount the SD card
sudo umount /media/SDCARD
```

## Setup Bootargs in U-boot

```bash
setenv bootargs 'console=ttyO0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait init=/sbin/init'
# console is set depends on the machine
```

# Creating initramfs

`initramfs` (initial ramdisk filesystem) is a temporary, early root filesystem that is mounted before the real root filesystem becomes available during the Linux kernel's initialization process. It is commonly used in the boot process to perform tasks such as loading essential kernel modules, configuring devices, and preparing the system for the transition to the actual root filesystem.

## Sequence of instruction

An initial RAM filesystem, or initramfs, is a compressed cpio archive. cpio is an old Unix archive format, similar to TAR and ZIP but easier to decode and so requiring less code in the kernel. You need to configure your kernel with **CONFIG_BLK_DEV_INITRD** to support initramfs.

Make sure do not includes kernel modules in the initramfs as it will take much space.

```bash
cd ~/rootfs
find . | cpio -H newc -ov --owner root:root > ../initramfs.cpio
cd ..
gzip initramfs.cpio
mkimage -A arm -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
```

## Booting with initramfs

Copy uRamdisk you created earlier in this section to the boot partition on the microSD card, and then use it to boot to point that you get a U-Boot prompt. Then enter these commands:

```bash
# make sure the variable initramfs doesn't overwrite the dtb and zimage variables
setenv initramfs [chose a value depends on bdinfo]

fatload mmc 0:1 $kernel_addr_r zImage
fatload mmc 0:1 $fdt_addr_r am335x-boneblack.dtb
fatload mmc 0:1 $initramfs uRamdisk
setenv bootargs console=ttyO0,115200 rdinit=/bin/sh

bootz $kernel_addr_r $initramfs $fdt_addr_r
```

In bootargs variable you need to configure like this

### Qemu

```bash
setenv bootargs "console=ttyAMA0 rdinit=/bin/sh"
```

### BeagleBone

```bash
setenv bootargs "console=ttyO0,115200 rdinit=/bin/sh"
```

## NOTE about initramfs

So far, we have created a compressed initramfs as a separate file and used the bootloader to load it into memory. Some bootloaders do not have the ability to load an initramfs file in this way. To cope with these situations, Linux can be configured to incorporate initramfs into the kernel image. To do this, change the kernel configuration and set **CONFIG_INITRAMFS_SOURCE** to the full path of the cpio archive you created earlier. If you are using menuconfig, it is in General setup | Initramfs source file(s). Note that it has to be the uncompressed cpio file ending in .cpio, not the gzipped version. Then, build the kernel.

# System configuration and startup 

The first user space program that gets executed by the kernel is `/sbin/init` and its configuration
file is `/etc/inittab`. in `inittab` we are executing `::sysinit:/etc/init.d/rcS`but this file doesn't exist.

create `/etc/init.d/rcS` startup script and in this script mount `/proc` `/sys` filesystems:

```sh 
#!/bin/sh
# mount a filesystem of type `proc` to /proc
mount -t proc nodev /proc
# mount a filesystem of type `sysfs` to /sys
mount -t sysfs nodev /sys
# you can create `/dev` and execute `mdev -s` if you missed the `devtmpfs` configuration  
```

Note: `can't run '/etc/init.d/rcS': Permission denied` , use 

```sh
#inside `rootfs` folder
chmod +x ./etc/init.d/rcS # to give execution permission for rcS script
#restart
```

