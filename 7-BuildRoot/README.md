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

`In case of using systemD increase the root file system size from build root configuartion`

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

#### WARNING it will take up to 2 hours ####
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

## Boot The System

### Qemu

```bash
# Run the system on Qemu
qemu-system-arm -M vexpress-a9 -m 128M -sd output/image/sdcard.img -kernel output/image/u-boot.img -nograhic
```

### BeagleBone

```bash
# First we need to format the sd card
dd if=/dev/zero of=/dev/mmcblk0 bs=1M
#### warning it will take some time ####

# Add the Sd image to the SD card
dd if=output/images/sdcard.img of=/dev/mmcblk0 bs=1M
```

### Raspberry Pi

```bash
# First we need to format the sd card
dd if=/dev/zero of=/dev/mmcblk0 bs=1M
#### warning it will take some time ####

# Add the Sd image to the SD card
dd if=output/images/sdcard.img of=/dev/mmcblk0 bs=1M
```

# Create Buildroot Package

Suppose you have a personalized package named "**simpleapp**" that you want to add to your Root File System (Root FS) that you are creating with buildroot. In the simplest scenario, this package would include a source file and a makefile.

1.  Create folder under package as following

```bash
mkdir -p ./package/simpleapp/src
```

2. Create source file under **src** and write a simple code

```bash
touch simpleapp && vim simpleapp
# or for shortcut
vim simpleapp
```

Inside the simple app write the following simple code

```c
#include <stdio.h>

int main(void) {
	printf("Hi People\r\n");
}
```

3. No we need to create the Makefile that buildroot will use it to compile the following app

```bash
# under src directory create Makefile
touch Makefile
# edit the Makefile
vim Makefile
```

Inside the Makefile write the following recipe

```makefile

.PHONY: clean
.PHONY: simpleapp

simpleapp: simpleapp.c
        $(CC) -g -Wall $(CFLAGS) $(LDFLAGS) $< -o $@

clean:
        -rm simpleapp
        
#### NOTE: Makefile requires a tab character for indentation. Spaces will not work. ####

```

4. Create a package definition for this package in the buildroot source tree.

```
# under package/simpleapp create the following Makefile
touch simpleapp.mk
# and edit the makefile
vim simpleapp.mk
```

Add the following script inside the makefile

```makefile
################################################################################
#
# simpleapp package
#
################################################################################

SIMPLEAPP_VERSION = 1.0
SIMPLEAPP_SITE = package/simpleapp/src
SIMPLEAPP_SITE_METHOD = local# Other methods like git,wget,scp,file etc. are also available.

define SIMPLEAPP_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define SIMPLEAPP_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/simpleapp  $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))

```

Then create the configuration file that will be used by builroot to show the package in menuconfig

```bash
touch Config.in && vim Config.in
```

Inside the file add the following configuration

```bash
config BR2_PACKAGE_SIMPLEAPP
    bool "simpleapp"
    help
        simpleapp package.
```

5. Add the new Config.in in the configuration for buildroot

Under **package directory**

```bash
vim ./package/Config.in
```

Add new menu under Target Package

```makefile
menu "SIMPLEAPP Packages"
    source "package/simpleapp/Config.in"
endmenu
```

6. Enable the package in buildroot menuconfig

```bash
# change directory to builroot
cd builroot
# configure the builroot
make menuconfig

# under target package you will find simpleapp
# add it to the configuration
```

7. Build builroot again

After building the builroot the execution file for simple app will be add it to the rootfs

```bash
# build the buildroot
make -j8
```

# Tips and Tricks

We can create a file to give U-Boot commands without setting the bootloader manually. 

```bash
# Create a folder and file in the `boot` partition:
mkdir extlinux && touch extlinux/extlinux.conf
```

Add the following content in the file

```bash
label buildroot
        kernel /zImage
        devicetree /am335x-boneblack.dtb
        append console=ttyO0,115200 root=/dev/mmcblk0p2 rootwait
```

