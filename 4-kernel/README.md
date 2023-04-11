# Linux Kernel

The Linux kernel is the core component of the Linux operating system, responsible for managing system resources such as memory, processes, input/output (I/O), and device drivers. It is an open-source software project that was initially developed by Linus Torvalds in 1991 and is now maintained by a large community of developers around the world.

## Download Linux Kernel

### Vexpress (Qemu)

```bash
git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
git checkout v5.19.6

#configure the kernel to vexpress
make vexpress_defconfig
```

### Raspberry Pi

```bash
git clone --depth=1 https://github.com/raspberrypi/linux
cd linux

#configure the kernel to rpi depends on the SoC number
make bcmXXXX_defconfig
```

### BeagleBone

```bash
git clone --depth=1 https://github.com/beagleboard/linux.git
cd linux

#configure the kernel to beaglebone
make bb.org_defconfig
```

## Configure Kernel

For all the next board this configuration must be checked

- [ ] Enable **devtmpfs**
- [ ] Change kernel compression to **XZ**

### Vexpress (Qemu)

```bash
#export the compiler
export CROSS_COMPILE=PathToCompiler/arm-linux-cortexa9Compiler
#export the architecture used
export ARCH=arm

#configure the kernel with the configuration discuss above
make menuconfig

#build the kernel
make -j12 zImage modules dtbs
```

### Raspberry PI

```bash
#export the compiler
export CROSS_COMPILE=arm-linux-gnueabihf-
#export the architecture used
export ARCH=arm

#configure the kernel with the configuration discuss above
make menuconfig

#build the kernel
make -j12 zImage modules dtbs
```

### BeagleBone

```bash
#export the compiler
export CROSS_COMPILE=PathToCompiler/arm-linux-cortexa9Compiler
#export the architecture used
export ARCH=arm

#configure the kernel with the configuration discuss above
make menuconfig

#build the kernel
make -j12 zImage modules dtbs
```

## Boot from TFTP server

### Vexpress (Qemu)

Copy the zImage and dtb file to the **tftp server**

```bash
cp linux/arch/arm/boot/zImage /srv/tftp/
cp linux/arch/arm/boot/dts/*-ca9.dtb /srv/tftp/
```

Start Qemu to boot on U-boot

```bash
sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel u-boot -sd sd.img -net tap,script=./qemu-ifup -net nic
```

Set the bootargs to

```bash
setenv bootargs console=ttyAMA0 
saveenv
```

load kernel image `zImage` and DTB `vexpress-v2p-ca9.dtb` from TFTP into RAM

```bash
tftp 0x61000000 zImage
tftp 0x62000000 vexpress-v2p-ca9.dtb
```

boot the kernel with its device tree

```
bootz 0x61000000 - 0x62000000
```

########## THE KERNEL WONT BOOT IT WILL **PANIC** ###########

### Raspberry PI

Copy the zImage and dtb file to the **tftp server**

```bash
cp linux/arch/arm/boot/zImage /srv/tftp/
cp linux/arch/arm/boot/dts/*-ca9.dtb /srv/tftp/
```

**Plug the Power to RPI and make sure to stop at the U-Boot stage**

Set the `bootargs` to

```bash
setenv bootargs console=ttyXXX 
saveenv

# get the console tty from cmdline
```

load kernel image `zImage` and DTB `vexpress-v2p-ca9.dtb` from TFTP into RAM

```bash
tftp [Address RAM kernel] zImage
tftp [Address RAM dtb] bcmXXXX-rpi-X.dtb

#get this address from bdinfo
```

boot the kernel with its device tree

```
bootz [Address RAM kernel] - [Address RAM dtb]
```

########## THE KERNEL WONT BOOT IT WILL **PANIC** ###########

### BeagleBone

Copy the zImage and dtb file to the **tftp server**

```bash
cp linux/arch/arm/boot/zImage /srv/tftp/
cp linux/arch/arm/boot/dts/*-ca9.dtb /srv/tftp/
```

**Plug the Power to RPI and make sure to stop at the U-Boot stage**

Set the `bootargs` to

```bash
setenv bootargs console=ttyS0 
saveenv
```

load kernel image `zImage` and DTB `vexpress-v2p-ca9.dtb` from TFTP into RAM

```bash
tftp 0x82000000 zImage
tftp 0x88000000 bcmXXXX-rpi-X.dtb

#get this address from bdinfo
```

boot the kernel with its device tree

```
bootz 0x82000000 - 0x88000000
```

########## THE KERNEL WONT BOOT IT WILL **PANIC** ###########