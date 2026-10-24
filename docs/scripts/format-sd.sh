#!/bin/bash
#
# Partition and format an SD card (or a loop device backed by sd.img) with the
# layout used in the U-Boot lesson:
#   p1: 200 MiB, FAT16, bootable, label "boot"
#   p2: rest of the disk, ext4, label "rootfs"
#
# Usage: ./format-sd.sh <drive>
#        drive is the name under /dev, e.g. 'sdb', 'mmcblk0', 'loop0'
#
# WARNING: this ERASES the whole drive.

if [ $# -ne 1 ]; then
	echo "Usage: $0 <drive>"
	echo "       drive is 'sdb', 'mmcblk0', 'loop0'"
	exit 1
fi

DRIVE=$1

# Check the drive exists in /sys/block
if [ ! -e /sys/block/${DRIVE}/size ]; then
	echo "Drive /dev/${DRIVE} does not exist"
	exit 1
fi

# Refuse anything bigger than ~64 GB (in 512-byte sectors): it is probably not an SD card
NUM_SECTORS=$(cat /sys/block/${DRIVE}/size)
if [ "$NUM_SECTORS" -eq 0 ] || [ "$NUM_SECTORS" -gt 125000000 ]; then
	echo "/dev/${DRIVE} does not look like an SD card, bailing out"
	exit 1
fi

# mmcblkX and loopX name their partitions with a 'p' (mmcblk0p1), sdX does not (sdb1)
case "$DRIVE" in
	mmcblk*|loop*) PART_PREFIX=/dev/${DRIVE}p ;;
	*)             PART_PREFIX=/dev/${DRIVE} ;;
esac
BOOT_PART=${PART_PREFIX}1
ROOT_PART=${PART_PREFIX}2

read -r -p "This will ERASE /dev/${DRIVE}. Type 'yes' to continue: " ANSWER
[ "$ANSWER" = "yes" ] || exit 1

# Unmount any partitions that have been automounted
sudo umount ${PART_PREFIX}* 2>/dev/null

# Overwrite the existing partition table with zeros
sudo dd if=/dev/zero of=/dev/${DRIVE} bs=1M count=10 || { echo "Error: dd"; exit 1; }

# Create 2 primary partitions: FAT16 (type 0x06, bootable) and Linux
sudo sfdisk /dev/${DRIVE} << EOF || { echo "Error: sfdisk"; exit 1; }
,200M,0x06,*
,,L,
EOF

# Ask the kernel to re-read the partition table (needed for loop devices)
sudo partprobe /dev/${DRIVE} 2>/dev/null

sudo mkfs.vfat -F 16 -n boot ${BOOT_PART} || { echo "Error: mkfs.vfat"; exit 1; }
sudo mkfs.ext4 -F -L rootfs ${ROOT_PART}  || { echo "Error: mkfs.ext4"; exit 1; }

echo "Done: ${BOOT_PART} (FAT16 boot) and ${ROOT_PART} (ext4 rootfs)"
exit 0
