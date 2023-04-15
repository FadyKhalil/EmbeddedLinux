# BuildRoot

## Download Required Library

```bash
sudo apt install sed make binutils gcc g++ bash patch \
gzip bzip2 perl tar cpio python unzip rsync wget libncurses-dev
```

## Download BuildRoot

```bash
git clone https://github.com/buildroot/buildroot.git
cd buildroot

#to Require help
make help
```

## Configuration

To List all board configuration supported by Buildroot 

```bash
make list-defconfigs

# Or you can list the files inside 
ls configs/
```

### Configure  Beaglebone

```bash
#configure beaglebone to buildroot
make beaglebone_defconfig
```

### Configure Raspberry Pi

```bash
# listing the defconfigs you will find several rasberry Pi
# Example
make raspberrypi3_defconfig
```

### Configure Qemu

```bash
# configure qemu vexpress
make qemu_arm_vexpress_defconfig
```

### Configure buildroot

```bash
# to configure the buildroot
make menuconfig
```

In the configuration, configure the following **requirement**:

- [ ]  Init procecss to **System V** or **System D** or **Busybox init**
- [ ]  Change **system host**
- [ ] Change **system banner**
- [ ]  Appy **root password**

#### Configure SSH

In order to configure SSH and add the executable in rootfs in **buildroot**

- [ ]  Enable in **Network application** configure **dropbear**
- [ ]  Set **Root password** in **system configuration**

## Build the System

```bash
# It will build the buildroot 
# Register the logs for debugging
make 2>&1 | tee build.log
```

## Configure Embedded Linux Component

### Configure Linux

```bash
# to change configuration for linux 
make linux-menuconfig
```

### Configure uboot

```bash
# to configure uboot
make uboot-menuconfig
```

### Configure Busybox

```bash
# to configure busybox
make busybox-menuconfig
```