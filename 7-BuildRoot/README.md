# 7 - Buildroot

> Let Buildroot build the toolchain, bootloader, kernel and root filesystem for you, then add your own package.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~30 min of work + 1-2 hours first build |
| **Previous** | [6 - Init process](../6-InitProcess/README.md) |
| **Next** | [8 - Yocto Project](../8-Yocto/README.md) |

## What you will learn

- How Buildroot automates everything you did by hand in lessons 2-6
- How to start from a board `defconfig` and customise the system
- How to reconfigure the kernel, U-Boot and BusyBox from inside Buildroot
- How to boot the generated image
- How to add **your own package** to the root filesystem

## Prerequisites

- Lessons 2-6, so you know what each piece does
- About 15 GB of free disk space
- Host packages:

```bash
sudo apt install sed make binutils build-essential diffutils gcc g++ bash patch \
    gzip bzip2 perl tar cpio unzip rsync file bc findutils wget python3 libncurses-dev
```

## Background

Buildroot is a set of Makefiles and patches. From one configuration file it produces:

| Output (`output/images/`) | What you built by hand |
|---|---|
| Toolchain (in `output/host/`) | Lesson 2 |
| `u-boot.bin` / `MLO`, `u-boot.img` | Lesson 3 |
| `zImage`, `*.dtb` | Lesson 4 |
| `rootfs.ext2` / `rootfs.tar` | Lessons 5 and 6 |
| `sdcard.img` | Everything combined, ready to write to an SD card |

## Steps

### 1. Download Buildroot

```bash
git clone https://github.com/buildroot/buildroot.git
cd buildroot
git checkout 2024.02          # long-term support release; pick the latest LTS

make help                     # list every target Buildroot understands
```

### 2. Load a board configuration

```bash
# list all supported boards
make list-defconfigs          # or: ls configs/
```

| Board | Command |
|---|---|
| QEMU vexpress-a9 | `make qemu_arm_vexpress_defconfig` |
| Raspberry Pi 3 | `make raspberrypi3_defconfig` |
| Raspberry Pi 4 | `make raspberrypi4_defconfig` |
| BeagleBone Black | `make beaglebone_defconfig` |

### 3. Customise the system

```bash
make menuconfig
```

Apply these requirements:

| Requirement | Where in menuconfig |
|---|---|
| Init system: **BusyBox**, **System V** or **systemd** | System configuration → Init system |
| Change the **hostname** | System configuration → System hostname |
| Change the **banner** | System configuration → System banner |
| Set a **root password** | System configuration → Root password |
| Add an **SSH server** | Target packages → Networking applications → dropbear |

> With **systemd**, also increase Filesystem images → exact size (e.g. `256M`), otherwise the rootfs may not fit.

### 4. Build

```bash
# keep a log for debugging
make 2>&1 | tee build.log
```

⏳ The first build downloads and compiles everything and can take **1-2 hours**. Later builds are much faster.

### 5. Reconfigure individual components

```bash
make linux-menuconfig       # kernel
make uboot-menuconfig       # U-Boot (boards that use it)
make busybox-menuconfig     # BusyBox

make                        # rebuild after any change
```

### 6. Boot the system

#### QEMU

```bash
# Buildroot generates a launcher script for QEMU boards
./output/images/start-qemu.sh
```

Or the full command (from `board/qemu/arm-vexpress/readme.txt`):

```bash
qemu-system-arm -M vexpress-a9 -smp 1 -m 256 \
    -kernel output/images/zImage \
    -dtb output/images/vexpress-v2p-ca9.dtb \
    -drive file=output/images/rootfs.ext2,if=sd,format=raw \
    -append "console=ttyAMA0,115200 rootwait root=/dev/mmcblk0" \
    -serial stdio -net nic,model=lan9118 -net user
```

#### Raspberry Pi and BeagleBone Black

```bash
# ⚠️ find your SD card with lsblk first; this overwrites it completely
sudo dd if=output/images/sdcard.img of=/dev/mmcblk<x> bs=4M conv=fsync status=progress
```

Put the card in the board and power it on (BeagleBone: hold **S2**).

### 7. Add your own package

Suppose you have an application `simpleapp` (one source file and a Makefile) that you want in the rootfs.
A Buildroot package needs three files:

```text
package/simpleapp/
├── Config.in          # makes it appear in menuconfig
├── simpleapp.mk       # tells Buildroot how to build and install it
└── src/
    ├── simpleapp.c    # your code
    └── Makefile       # how to compile it
```

#### 7.1 Source code

```bash
mkdir -p package/simpleapp/src
vim package/simpleapp/src/simpleapp.c
```

```c
#include <stdio.h>

int main(void) {
	printf("Hi People\r\n");
	return 0;
}
```

#### 7.2 The app's Makefile

`package/simpleapp/src/Makefile` (**recipe lines must start with a Tab**, not spaces):

```makefile
.PHONY: clean

simpleapp: simpleapp.c
	$(CC) -g -Wall $(CFLAGS) $(LDFLAGS) $< -o $@

clean:
	-rm -f simpleapp
```

#### 7.3 The package recipe

`package/simpleapp/simpleapp.mk`:

```makefile
################################################################################
#
# simpleapp package
#
################################################################################

SIMPLEAPP_VERSION = 1.0
SIMPLEAPP_SITE = package/simpleapp/src
# local = take the source from a folder; git, wget, scp, file... are also available
SIMPLEAPP_SITE_METHOD = local

define SIMPLEAPP_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define SIMPLEAPP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/simpleapp $(TARGET_DIR)/usr/bin/simpleapp
endef

$(eval $(generic-package))
```

#### 7.4 The menu entry

`package/simpleapp/Config.in`:

```bash
config BR2_PACKAGE_SIMPLEAPP
	bool "simpleapp"
	help
	  simpleapp package.
```

Then add it to Buildroot's package menu by editing `package/Config.in`, inside `menu "Target packages"`:

```makefile
menu "SIMPLEAPP Packages"
	source "package/simpleapp/Config.in"
endmenu
```

#### 7.5 Enable and build

```bash
make menuconfig       # Target packages → SIMPLEAPP Packages → [*] simpleapp
make -j$(nproc)
```

After changing the source later, rebuild only your package and the image:

```bash
make simpleapp-rebuild all
```

## Checkpoint

```text
Welcome to Buildroot
buildroot login: root
Password:
# simpleapp
Hi People
```

(The banner and hostname are the ones you set in step 3.)

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `You seem to have the current working directory in your PATH` | `.` or an empty entry in `PATH` | Remove it, e.g. open a fresh terminal |
| `Makefile: *** missing separator` | Spaces instead of a Tab in a recipe | Use a real Tab character |
| `simpleapp` not in menuconfig | `package/Config.in` not edited, or typo in `source` path | Check step 7.4 |
| Build fails after changing a toolchain/arch option | Old build artefacts | `make clean all` (full rebuild) |
| systemd image: `No space left on device` | Rootfs size too small | Increase the filesystem size (step 3 note) |

## Tips and tricks

### Boot without typing U-Boot commands: `extlinux.conf`

U-Boot can read a boot menu from the boot partition, so you don't have to type `bootargs` by hand:

```bash
# on the boot (FAT) partition
mkdir extlinux && touch extlinux/extlinux.conf
```

```text
label buildroot
	kernel /zImage
	devicetree /am335x-boneblack.dtb
	append console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait
```

## Exercises

1. Switch the init system to systemd and add the `deamonapp.service` from [lesson 6](../6-InitProcess/README.md) using a rootfs overlay (*System configuration → Root filesystem overlay directories*).
2. Change `simpleapp` to print the hostname, then use `make simpleapp-rebuild all`.
3. Run `make savedefconfig BR2_DEFCONFIG=configs/my_board_defconfig` to save your configuration.

## Recap

- One `make` now produces everything you built by hand, and custom packages slot in with three small files.
- Next, the **Yocto Project** does the same at industrial scale with layers and recipes.
