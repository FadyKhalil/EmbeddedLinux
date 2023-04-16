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

