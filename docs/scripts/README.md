# Helper scripts

Small scripts used in several lessons. Download them from the
[repository](https://github.com/FadyKhalil/EmbeddedLinux/tree/main/docs/scripts) or clone it.

| Script | Used in | What it does |
|---|---|---|
| [`setenv-cross.sh`](setenv-cross.sh) | Lessons 2-6 | Puts your Crosstool-NG toolchain in `PATH` and exports `CROSS_COMPILE` and `ARCH`. Use it with `source` |
| [`format-sd.sh`](format-sd.sh) | Lessons 3, 5 | ⚠️ Partitions and formats an SD card or loop device (200 MB FAT16 boot + ext4 rootfs) |
| [`qemu-ifup`](qemu-ifup) | Lessons 3-6 | Gives the host side of QEMU's network the address `192.168.0.1` |
| [`run-qemu-uboot.sh`](run-qemu-uboot.sh) | Lessons 3-6 | Starts QEMU vexpress-a9 with U-Boot, the virtual SD card and networking |
