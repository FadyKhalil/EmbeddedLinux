#!/bin/sh
# Boot U-Boot in QEMU (vexpress-a9) with the emulated SD card and a TAP network
# interface configured by qemu-ifup (host side gets 192.168.0.1).
#
# Usage: ./run-qemu-uboot.sh [path/to/u-boot] [path/to/sd.img]

UBOOT=${1:-u-boot/u-boot}
SDIMG=${2:-sd.img}
SCRIPT_DIR=$(dirname "$0")

sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic \
	-kernel "$UBOOT" \
	-sd "$SDIMG" \
	-net tap,script="$SCRIPT_DIR/qemu-ifup" -net nic
