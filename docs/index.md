---
hide:
  - navigation
  - toc
---

<div class="el-hero" markdown>

# Embedded Linux From Scratch

Build a complete embedded Linux system **one piece at a time**: first by hand (toolchain, bootloader,
kernel, root filesystem, init), then with the build systems used in industry, **Buildroot** and **Yocto**.

Every lesson works on **QEMU** (no hardware needed), a **Raspberry Pi** or a **BeagleBone Black**.

[Start with lesson 1](01-libraries/README.md){ .md-button .md-button--primary }
[View on GitHub](https://github.com/FadyKhalil/EmbeddedLinux){ .md-button }

</div>

## The big picture

Each lesson builds one stage of the boot chain. Press **Play** to follow a board from power-on to your own application.

<figure class="el-anim">
<img src="boot-chain.svg" alt="Boot chain: ROM code, SPL, U-Boot, kernel and device tree, root filesystem, init, your application">
<ol class="el-anim-steps">
<li><b>Power on.</b> The SoC runs its <b>ROM code</b>, burned into the chip at the factory. It only knows how to find the next stage on a boot device (SD card, eMMC, network...).</li>
<li>The ROM loads a tiny <b>first-stage loader</b> (SPL, called <code>MLO</code> on the BeagleBone). Its main job is to initialise the external RAM, because the full bootloader doesn't fit in the SoC's internal memory. On the Raspberry Pi, the GPU firmware plays this role.</li>
<li><b>U-Boot</b> starts. It sets up the clocks, serial console, storage and network, then loads the kernel and device tree into RAM. <i>You build it in lesson 3.</i></li>
<li>The <b>Linux kernel</b> starts and reads the <b>device tree</b> (DTB) to learn which hardware the board has. <i>Lesson 4.</i></li>
<li>The kernel mounts the <b>root filesystem</b>: the programs, libraries and configuration files. <i>Lesson 5.</i></li>
<li>The kernel starts <code>/sbin/init</code> as <b>PID 1</b>. Init brings up the rest of the system. <i>Lesson 6.</i></li>
<li>Your <b>application</b> runs. In this course that's <code>heartbeat</code>, a small daemon you'll build, start at boot, and later package with Buildroot and Yocto.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/">course website</a>.</figcaption>
</figure>

## Learning path

Follow the lessons in order: each one uses what the previous one produced.

| # | Lesson | You will build / learn | Used later as |
|---|---|---|---|
| 1 | [Libraries](01-libraries/README.md) | Static vs. shared libraries, what has to be on the target | Understanding `.a` / `.so` in the rootfs |
| 2 | [Cross toolchain](02-toolchain/README.md) | Your own ARM cross compiler with Crosstool-NG | `~/x-tools/<tuple>/bin/*-gcc` |
| 3 | [U-Boot](03-u-boot/README.md) | Bootloader, SD card layout, TFTP | `u-boot`, SD card, TFTP server |
| 4 | [Linux kernel](04-kernel/README.md) | Configure, build and boot a kernel + device tree | `zImage`, `*.dtb` |
| 5 | [Root filesystem](05-rootfs/README.md) | A BusyBox rootfs over NFS, SD card and initramfs | `~/rootfs/` |
| 6 | [Init process](06-init/README.md) | Start `heartbeat` with BusyBox init, System V and systemd | A daemon started at boot |
| 7 | [Buildroot](07-buildroot/README.md) | The whole system in one `make`, plus `heartbeat` as a package | `sdcard.img` |
| 8 | [Yocto Project](08-yocto/README.md) | Layers, recipes, variables, tasks, `heartbeat` as a recipe | A custom image and layer |

The [CMake extra](extras/cmake/01-overview.md) shows how to cross-compile CMake projects for the board.

## Choose your board

You only need **one**. Each lesson has a section per board; skip the ones you don't use.

| Board | What you need | Good for |
|---|---|---|
| **QEMU vexpress-a9** (Cortex-A9) | Only your PC | Starting out, nothing to break |
| **Raspberry Pi 3 / 4** | Pi, microSD card, USB-to-serial (3.3 V) cable | Real hardware, easy to find |
| **BeagleBone Black** (Cortex-A8) | BBB, microSD card, USB-to-serial (3.3 V) cable | Real hardware, very well documented |

> [!TIP]
> On real hardware a **serial console** is essential: U-Boot and the early kernel only talk over the UART.

## Host setup

The lessons are written for **Ubuntu 22.04 / 24.04** (a virtual machine works). Plan for about
**100 GB** of free disk space if you'll do the Yocto lesson.

```bash
sudo apt update
sudo apt install -y build-essential git bc bison flex libssl-dev libncurses-dev \
    u-boot-tools qemu-system-arm device-tree-compiler \
    tftpd-hpa nfs-kernel-server cpio rsync wget unzip
```

Lessons that need more packages (Crosstool-NG, Buildroot, Yocto) list them at the top.

## Conventions used in every lesson

| Name | Meaning | Example |
|---|---|---|
| `CROSS_COMPILE` | Prefix of your cross compiler | `arm-cortexa9_neon-linux-gnueabihf-` |
| `ARCH` | Kernel / U-Boot architecture | `arm` (or `arm64` for 64-bit Pi) |
| `DISK` | Block device of the SD card (or loop device) | `/dev/mmcblk0`, `/dev/sdb`, `/dev/loop0` |
| Host IP | Your PC on the board network (TFTP / NFS server) | `192.168.0.1` |
| Target IP | The board | `192.168.0.100` |

- Commands run on your **host PC** unless the block starts with `# U-Boot prompt` or `# target shell`.
- Anything in `<angle brackets>` must be replaced with your own value.
- Commands that **erase disks** are inside a red warning box. Always check `DISK` with `lsblk` first.

Helper scripts used in several lessons are in [`scripts/`](scripts/README.md).
