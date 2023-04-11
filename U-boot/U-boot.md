# U-boot

U-Boot is **the most popular boot loader in** **linux** **based embedded devices**. It is released as open source under the GNU GPLv2 license. It supports a wide range of microprocessors like MIPS, ARM, PPC, Blackfin, AVR32 and x86.

## Setup U-boot

### Download U-Boot

```bash
git clone git@github.com:u-boot/u-boot.git
cd u-boot/
git checkout v2022.07
```

### Configure U-Boot Machine

In this section we will **configure** u-boot for several Machine

```bash
# In order to find the machine supported by U-Boot
ls configs/ | grep [your machine] 
```

#### Vexpress Cortex A9 (Qemu)

In **U-boot directory** Assign this value

```bash
# Set the Cross Compiler into the environment
# To be used by the u-boot
export CROSS_COMPILE=<Path To the Compiler>/arm-cortexa9_neon-linux-musleabihf-
export ARCH=arm

# load the default configuration of ARM Vexpress Cortex A9
make vexpress_ca9x4_defconfig
```

#### Raspberry Pi

First we need to download the **compiler** for the architecture set for **RPI**

```bash
sudo apt-get install arm-linux-gnueabihf-
```

##### Raspberry Pi 3

In **U-boot directory** Assign this value

```bash
# Set the Cross Compiler into the environment
# To be used by the u-boot
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

# load the default configuration of rpi 3
make rpi_3_defconfig
```

##### Raspberry Pi 4

In **U-boot directory** Assign this value

```bash
# Set the Cross Compiler into the environment
# To be used by the u-boot
export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm

# load the default configuration of rpi 3
make rpi_4_32b_defconfig
```

#### Beaglebone

In **U-boot directory** Assign this value

```bash
# Set the Cross Compiler into the environment
# To be used by the u-boot
export CROSS_COMPILE=<Path To the Compiler>/arm-cortexa9_neon-linux-musleabihf-
export ARCH=arm

# load the default configuration of ARM Vexpress Cortex A9
make am335x_evm_defconfig
```

### Configure U-Boot 

In this part we need to configure some u-boot configuration for the specific board chosen up.

```bash
make menuconfig
```

**The customer requirement are like following**:

- [ ] Support **editenv**.
- [ ] Support **bootd**.
- [ ] Store the environment variable inside file call **uboot.env**.
- [ ] Unset support of **Flash**
- [ ] Support **FAT file system**
  - [ ] Configure the FAT interface to **mmc**
  - [ ] Configure the partition where the fat is store to **0:1**