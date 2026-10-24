# 8 · Yocto Project

> Build a custom Linux image with the Yocto Project for QEMU, Raspberry Pi or BeagleBone, then learn layers, recipes and variables step by step.

| | |
|---|---|
| **Boards** | QEMU · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1 hour of work + 2-6 hours first build |
| **Previous** | [7 - Buildroot](../07-buildroot/README.md) |
| **Next** | [8.1 · Yocto terminology](01-terminology.md) |

## What you will learn

- What the Yocto Project and Poky are, and how they differ from Buildroot
- How to prepare a build host and set up a build directory
- How to build `core-image-minimal` for QEMU and real boards
- How to add BSP layers and write the image to an SD card

## Prerequisites

- [Lesson 7](../07-buildroot/README.md) recommended (same ideas, simpler tool)
- A supported Linux distribution (Ubuntu 22.04 / 24.04 work well)
- **At least 90 GB** of free disk and 8 GB of RAM (more cores = much faster builds)

## Background

The Yocto Project is a set of tools and metadata for creating **your own Linux distribution**.

| You give it (input) | It gives you (output) |
|---|---|
| A specification: hardware (`MACHINE`), kernel configuration, packages to install, distro policy | Bootloader, Linux kernel, device tree, root filesystem, and an SDK / toolchain |

Compared to Buildroot, Yocto is bigger and slower to learn, but builds **packages** (ipk/rpm/deb), scales
to many products through **layers**, and is the standard in most companies.

This lesson uses the **scarthgap** release (Yocto 5.0, long-term support until April 2028).
Use the same branch name for **every** layer you clone. Check the
[releases page](https://wiki.yoctoproject.org/wiki/Releases) for the current LTS.

## Steps

### 1. Install the host packages

```bash
sudo apt install build-essential chrpath cpio debianutils diffstat file gawk gcc git \
    iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 \
    python3-pexpect python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd
sudo locale-gen en_US.UTF-8
```

### 2. Download Poky

```bash
mkdir -p ~/yocto && cd ~/yocto
git clone -b scarthgap https://git.yoctoproject.org/poky
```

### 3. Create a build directory

```bash
cd ~/yocto
source poky/oe-init-build-env build      # creates ~/yocto/build and cd's into it
```

> [!TIP]
> Run this `source` command in **every new terminal** before using `bitbake`.

`build/conf/` now contains the two files you'll edit most:
`local.conf` (what to build) and `bblayers.conf` (which layers to use).
See [Folder description](03-build-config.md) for every variable in them.

### 4. (Optional) tune parallelism

By default BitBake uses all your CPU cores. If your PC runs out of RAM during the build, limit it in
`conf/local.conf`:

```bash
# number of BitBake tasks running at the same time
BB_NUMBER_THREADS = "4"
# number of parallel compile jobs inside each task (make -j)
PARALLEL_MAKE = "-j 4"
```

### 5. Build for your board

#### QEMU

The default `MACHINE` is already `qemux86-64`, so just build:

```bash
bitbake core-image-minimal
runqemu qemux86-64 nographic      # log in as root, no password
```

To emulate an ARM board instead, set `MACHINE = "qemuarm"` in `conf/local.conf`.

#### Raspberry Pi

```bash
cd ~/yocto
git clone -b scarthgap https://git.yoctoproject.org/meta-raspberrypi
git clone -b scarthgap https://git.openembedded.org/meta-openembedded    # useful extra recipes

cd ~/yocto/build
bitbake-layers add-layer ../meta-raspberrypi
bitbake-layers show-layers
```

In `conf/local.conf`:

```bash
MACHINE = "raspberrypi4"         # raspberrypi3, raspberrypi4-64, ...
ENABLE_UART = "1"                # serial console on the GPIO header
```

```bash
bitbake core-image-minimal
```

#### BeagleBone Black

Poky's own `meta-yocto-bsp` layer already supports the BeagleBone, so no extra layer is needed.
In `conf/local.conf`:

```bash
#MACHINE ??= "qemux86-64"
MACHINE = "beaglebone-yocto"
```

```bash
bitbake core-image-minimal
```

> [!NOTE]
> For TI's full BSP (more drivers, TI kernel) you can use [meta-ti](https://git.yoctoproject.org/meta-ti) instead,
> with `MACHINE = "beaglebone"`.

### 6. Write the image to an SD card

Images are in `tmp/deploy/images/<machine>/`. Both boards produce a ready-to-flash **`.wic`** image:

```bash
cd ~/yocto/build/tmp/deploy/images/<machine>/
lsblk                                                     # find your SD card

# ⚠️ Raspberry Pi (compressed .wic.bz2)
bzcat core-image-minimal-raspberrypi4.rootfs.wic.bz2 | sudo dd of=/dev/mmcblk<x> bs=4M conv=fsync status=progress

# ⚠️ BeagleBone Black (.wic)
sudo dd if=core-image-minimal-beaglebone-yocto.rootfs.wic of=/dev/mmcblk<x> bs=4M conv=fsync status=progress
```

## Checkpoint

```text
Poky (Yocto Project Reference Distro) 5.0.x raspberrypi4 /dev/ttyS0

raspberrypi4 login: root
root@raspberrypi4:~#
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `bitbake: command not found` | Environment not sourced in this terminal | `source poky/oe-init-build-env build` |
| `Layer ... is not compatible with the core layer` | Layer on a different branch than poky | `git checkout scarthgap` in that layer |
| `User namespaces are not usable by BitBake` (Ubuntu 24.04) | AppArmor restricts unprivileged user namespaces | Follow the Ubuntu 24.04 note in the [Yocto system requirements](https://docs.yoctoproject.org/ref-manual/system-requirements.html) |
| Build killed / `Out of memory` | Too many parallel jobs for your RAM | Lower `BB_NUMBER_THREADS` and `PARALLEL_MAKE` (step 4) |
| `No space left on device` | Not enough disk | Free space, or add `INHERIT += "rm_work"` to `local.conf` |
| Fetch errors | Network / mirror | Re-run `bitbake`; finished tasks are cached |

## Exercises

1. Add `strace` to the image: `IMAGE_INSTALL:append = " strace"` in `local.conf` (note the leading space), rebuild, and run `strace ls` on the target.
2. Build `core-image-base` and compare the image size with `core-image-minimal`.
3. Run `bitbake -e core-image-minimal | grep ^MACHINE=` and check it matches what you set.

## Recap

- You built and booted a Yocto image and added a BSP layer.
- The sub-lessons explain what you just did: start with [terminology](01-terminology.md),
  then [layers](04-layers.md), [variables](05-variables.md) and [your first recipe](07-first-recipe.md).
