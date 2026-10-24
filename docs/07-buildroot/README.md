# 7 · Buildroot

> Let Buildroot build the toolchain, bootloader, kernel and root filesystem for you, then add `heartbeat` as your own package.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~30 min of work + 1-2 hours first build |
| **Previous** | [6 · Init process](../06-init/README.md) |
| **Next** | [8 · Yocto Project](../08-yocto/README.md) |

## What you will learn

- How Buildroot automates everything you did by hand in lessons 2-6
- How to start from a board `defconfig` and customise the system
- How to reconfigure the kernel, U-Boot and BusyBox from inside Buildroot
- How to boot the generated image
- How to add **your own package** with a `BR2_EXTERNAL` tree, without touching Buildroot's sources

## Prerequisites

- Lessons 2-6, so you know what each piece does
- About 15 GB of free disk space
- Host packages:

```bash
sudo apt install sed make binutils build-essential diffutils gcc g++ bash patch \
    gzip bzip2 perl tar cpio unzip rsync file bc findutils wget python3 libncurses-dev
```

## Background

Buildroot is a set of Makefiles and patches. From **one configuration file** it builds everything, in the right order:

<figure class="el-anim">
<img src="buildroot-flow.svg" alt="Buildroot pipeline: configuration, toolchain, U-Boot, kernel, packages, root filesystem, SD card image">
<ol class="el-anim-steps">
<li>You choose a board <b>defconfig</b> and adjust it in <code>make menuconfig</code>. This single <code>.config</code> file describes the whole system.</li>
<li>Buildroot first builds a <b>cross toolchain</b>, like you did with Crosstool-NG in lesson 2.</li>
<li>Then the <b>bootloader</b> (lesson 3)...</li>
<li>...the <b>kernel</b> and device trees (lesson 4)...</li>
<li>...and every selected <b>package</b>: BusyBox, dropbear, and your own <code>heartbeat</code> (lessons 5 and 6). Each one is installed into <code>output/target/</code>.</li>
<li><code>output/target/</code> is turned into a <b>root filesystem image</b>.</li>
<li>Finally everything is assembled into <code>sdcard.img</code>, ready to write to a card. One <code>make</code> did lessons 2-6.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/07-buildroot/index.html">course website</a>.</figcaption>
</figure>

| Output | What you built by hand |
|---|---|
| Toolchain in `output/host/` | Lesson 2 |
| `output/images/u-boot.bin` / `MLO`, `u-boot.img` | Lesson 3 |
| `output/images/zImage`, `*.dtb` | Lesson 4 |
| `output/images/rootfs.ext2` | Lessons 5 and 6 |
| `output/images/sdcard.img` | Everything combined |

## Steps

### 1. Download Buildroot

```bash
git clone https://github.com/buildroot/buildroot.git
cd buildroot
git checkout 2024.02          # long-term support release; pick the latest LTS

make help                     # list every target Buildroot understands
```

### 2. Load a board configuration, with the course's packages

The course ships a **`BR2_EXTERNAL` tree** in [`br2-external/`](https://github.com/FadyKhalil/EmbeddedLinux/tree/main/docs/07-buildroot/br2-external):
a folder of extra packages that Buildroot adds to its own. Pass it once; Buildroot remembers it in `output/.br2-external.mk`.

```bash
# list all supported boards
make list-defconfigs          # or: ls configs/
```

| Board | Command |
|---|---|
| QEMU vexpress-a9 | `make BR2_EXTERNAL=<path-to-this-repo>/docs/07-buildroot/br2-external qemu_arm_vexpress_defconfig` |
| Raspberry Pi 3 | `make BR2_EXTERNAL=<...>/br2-external raspberrypi3_defconfig` |
| Raspberry Pi 4 | `make BR2_EXTERNAL=<...>/br2-external raspberrypi4_defconfig` |
| BeagleBone Black | `make BR2_EXTERNAL=<...>/br2-external beaglebone_defconfig` |

### 3. Customise the system

```bash
make menuconfig
```

| Requirement | Where in menuconfig |
|---|---|
| Init system: **BusyBox**, **System V** or **systemd** | System configuration → Init system |
| Change the **hostname** | System configuration → System hostname |
| Change the **banner** | System configuration → System banner |
| Set a **root password** | System configuration → Root password |
| Add an **SSH server** | Target packages → Networking applications → dropbear |
| Add **heartbeat** | External options → Embedded Linux course packages → heartbeat |

> [!NOTE]
> With **systemd**, also increase *Filesystem images → exact size* (e.g. `256M`), otherwise the rootfs may not fit.

### 4. Build

```bash
# keep a log for debugging
make 2>&1 | tee build.log
```

> [!IMPORTANT]
> The first build downloads and compiles everything and can take **1-2 hours**. Later builds only rebuild what changed.

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

> [!CAUTION]
> `dd` overwrites the whole target device. Check the SD card's name with `lsblk` first.

```bash
sudo dd if=output/images/sdcard.img of=/dev/mmcblk<x> bs=4M conv=fsync status=progress
```

Put the card in the board and power it on (BeagleBone: hold **S2**).

### 7. How the `heartbeat` package works

A package needs two files. In a `BR2_EXTERNAL` tree they sit under `package/<name>/`, next to three small files that
hook the tree into Buildroot:

```text
br2-external/
├── external.desc            # name: COURSE   (gives you $(BR2_EXTERNAL_COURSE_PATH))
├── external.mk              # includes every package/*/*.mk
├── Config.in                # adds the packages to "External options" in menuconfig
└── package/heartbeat/
    ├── Config.in            # the menu entry
    └── heartbeat.mk         # how to fetch, build and install it
```

The menu entry:

```bash title="package/heartbeat/Config.in"
config BR2_PACKAGE_HEARTBEAT
	bool "heartbeat"
	help
	  Demo daemon of the Embedded Linux course.
```

The recipe. The sources come straight from [lesson 6](../06-init/README.md), and the init file that gets installed
depends on the init system you picked in step 3:

```makefile title="package/heartbeat/heartbeat.mk"
HEARTBEAT_VERSION = 1.0
HEARTBEAT_SITE = $(BR2_EXTERNAL_COURSE_PATH)/../../06-init/app
HEARTBEAT_SITE_METHOD = local

define HEARTBEAT_BUILD_CMDS
	$(MAKE) -C $(@D) clean
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define HEARTBEAT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/heartbeat $(TARGET_DIR)/usr/bin/heartbeat
endef

# BusyBox init and System V init
define HEARTBEAT_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/heartbeat.init $(TARGET_DIR)/etc/init.d/S40heartbeat
endef

# systemd
define HEARTBEAT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 $(@D)/heartbeat.service $(TARGET_DIR)/usr/lib/systemd/system/heartbeat.service
endef

$(eval $(generic-package))
```

| Variable / macro | Meaning |
|---|---|
| `HEARTBEAT_SITE` + `_SITE_METHOD = local` | Copy the sources from a local folder (other methods: `git`, `wget`, `scp`...) |
| `TARGET_CONFIGURE_OPTS` | `CC=`, `CFLAGS=`, `LDFLAGS=`... for Buildroot's cross toolchain |
| `$(@D)` | The package's build folder, `output/build/heartbeat-1.0/` |
| `$(TARGET_DIR)` | The future root filesystem, `output/target/` |
| `$(eval $(generic-package))` | Turns all of the above into the standard download/build/install steps |

> [!WARNING]
> Recipe lines in `.mk` files (inside `define ... endef`) must start with a **Tab**, not spaces.

After you change `heartbeat.c`, rebuild only the package and the images:

```bash
make heartbeat-rebuild all
```

## Checkpoint

```text
Welcome to Buildroot
buildroot login: root
Password:
# heartbeat: beat #5 at 10:42:19
# /etc/init.d/S40heartbeat status
heartbeat is running (pid 112)
```

(The banner and hostname are the ones you set in step 3. With systemd, use `systemctl status heartbeat`.)

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `You seem to have the current working directory in your PATH` | `.` or an empty entry in `PATH` | Remove it, e.g. open a fresh terminal |
| `Makefile: *** missing separator` | Spaces instead of a Tab in a recipe | Use a real Tab character |
| No "External options" menu | `BR2_EXTERNAL` not given | Re-run step 2 with `BR2_EXTERNAL=...` |
| heartbeat not started with systemd | Unit installed but not enabled | `systemctl enable heartbeat` once on the target |
| Build fails after changing toolchain/arch options | Old build artefacts | `make clean all` (full rebuild) |
| systemd image: `No space left on device` | Rootfs too small | Increase the filesystem size (step 3 note) |

## Tips and tricks

### Boot without typing U-Boot commands: `extlinux.conf`

U-Boot can read a boot menu from the boot partition, so you don't have to set `bootargs` by hand:

```text title="boot partition: extlinux/extlinux.conf"
label buildroot
	kernel /zImage
	devicetree /am335x-boneblack.dtb
	append console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait
```

### Save your configuration

```bash
make savedefconfig BR2_DEFCONFIG=<path-to-this-repo>/docs/07-buildroot/br2-external/configs/my_board_defconfig
```

Files in a `BR2_EXTERNAL` tree's `configs/` folder show up in `make list-defconfigs`.

## Exercises

1. Switch the init system between BusyBox, System V and systemd, and check that `heartbeat` starts each time.
2. Add a rootfs overlay (*System configuration → Root filesystem overlay directories*) that changes `/etc/issue`.
3. Make `heartbeat` beat every second: add `-i 1` to the start line in `06-init/app/heartbeat.init`, then `make heartbeat-rebuild all`.

## Recap

- One `make` now produces everything you built by hand, and your own software slots in as a package.
- Next, the **Yocto Project** does the same at industrial scale, with layers and recipes.
