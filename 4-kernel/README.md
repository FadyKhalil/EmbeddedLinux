# Linux Kernel

The Linux kernel is the core component of the Linux operating system, responsible for managing system resources such as memory, processes, input/output (I/O), and device drivers. It is an open-source software project that was initially developed by Linus Torvalds in 1991 and is now maintained by a large community of developers around the world.

## Download Linux Kernel

### Vexpress (Qemu)

```bash
git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux

#configure the kernel to vexpress
make ARCH=arm vexpress_defconfig

# To indentify your kernel version 
make ARCH=arm kernelversion
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
- [ ] Change your kernel local version to your name and append on it <youName>-v1.0

### Vexpress (Qemu)

```bash
#export the compiler
export CROSS_COMPILE=PathToCompiler/arm-linux-cortexa9Compiler
#export the architecture used
export ARCH=arm

#configure the kernel with the configuration discuss above
make menuconfig

#build the kernel
make -j4 zImage modules dtbs
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
make -j4 zImage modules dtbs
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
make -j4 zImage modules dtbs
```

### Compiling modules and store them in rootfs

The compiled modules have a .ko suffix and are generated in the same directory as the source code, meaning that they are scattered all around the kernel source tree.

To install them into the staging area of your root filesystem (we will talk about root filesystems in the next chapter), provide the path using **INSTALL_MOD_PATH**:

```bash
make -j4 ARCH=arm CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf- INSTALL_MOD_PATH=$HOME/rootfs modules_install
```

Kernel modules are put into the directory /lib/modules/[kernel version], relative to the root of the filesystem.

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
tftp $kernel_addr_r zImage
tftp $fdt_addr_r vexpress-v2p-ca9.dtb
```

boot the kernel with its device tree

```bash
bootz $kernel_addr_r - $fdt_addr_r
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
tftp 0x88000000 am3356-bb-X.dtb

# get this address from bdinfo
```

boot the kernel with its device tree

```
bootz 0x82000000 - 0x88000000
```

########## THE KERNEL WONT BOOT IT WILL **PANIC** ###########