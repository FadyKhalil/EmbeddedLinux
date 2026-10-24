# 4 · Linux Kernel

> Configure and cross-compile the Linux kernel and its device tree, then boot them from U-Boot over TFTP.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~30 min of work + 15-60 min build |
| **Previous** | [3 · U-Boot](../03-u-boot/README.md) |
| **Next** | [5 · Root filesystem](../05-rootfs/README.md) |

## What you will learn

- Where to get the right kernel source for your board
- How to start from a `defconfig` and customise it with `menuconfig`
- How to build the kernel image, modules and device trees
- How U-Boot hands over to the kernel with `bootz`
- Why the kernel **panics** at the end of this lesson, and what it needs next

## Prerequisites

- [Lesson 3](../03-u-boot/README.md) done: U-Boot runs, TFTP works, `ipaddr` / `serverip` are saved
- `CROSS_COMPILE` and `ARCH` exported (lesson 2)
- Host packages `bc bison flex libssl-dev libncurses-dev` (see the [home page](../index.md#host-setup))

## Background

The **Linux kernel** manages memory, processes, I/O and device drivers. To boot it, U-Boot needs two files in RAM:

| File | What it is |
|---|---|
| `zImage` (32-bit) / `Image` (64-bit) | The compressed kernel itself |
| `*.dtb` | The **device tree blob**: a description of the board's hardware (RAM, UARTs, Ethernet...), so one kernel binary can run on many boards |

U-Boot also passes the kernel a command line, the **`bootargs`** variable. It says, for example, which serial port
is the console (`console=`) and where the root filesystem is (`root=`).

<figure class="el-anim">
<img src="bootz.svg" alt="U-Boot downloads zImage and the device tree into RAM at kernel_addr_r and fdt_addr_r, then bootz starts the kernel with the device tree address in register r2">
<ol class="el-anim-steps">
<li>The kernel and device tree wait on your PC's TFTP server. U-Boot knows two safe RAM addresses for them: <code>${kernel_addr_r}</code> and <code>${fdt_addr_r}</code>.</li>
<li><code>tftp ${kernel_addr_r} zImage</code> copies the kernel into RAM.</li>
<li><code>tftp ${fdt_addr_r} board.dtb</code> copies the device tree next to it, without overlapping.</li>
<li><code>bootz</code> jumps to the kernel's first instruction and passes the device tree's address in CPU register <code>r2</code> (the ARM boot protocol). The <code>-</code> in the middle means "no initramfs".</li>
<li>The kernel decompresses itself, reads the device tree, starts its drivers... and then <b>panics</b>, because there's no root filesystem yet. That comes in lesson 5.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/04-kernel/index.html">course website</a>.</figcaption>
</figure>

## Steps

### 1. Get the kernel source

#### QEMU (vexpress)

```bash
# mainline stable kernel, 6.6 long-term branch
git clone --depth=1 -b linux-6.6.y https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
make kernelversion
```

#### Raspberry Pi

```bash
# the Raspberry Pi fork contains the Pi-specific drivers
git clone --depth=1 https://github.com/raspberrypi/linux
cd linux
```

#### BeagleBone Black

```bash
git clone --depth=1 https://github.com/beagleboard/linux.git
cd linux
```

### 2. Load the default configuration

| Board | 32-bit (`ARCH=arm`) | 64-bit (`ARCH=arm64`) |
|---|---|---|
| QEMU vexpress-a9 | `make vexpress_defconfig` | - |
| Raspberry Pi 3 | `make bcm2709_defconfig` | `make bcmrpi3_defconfig` |
| Raspberry Pi 4 | `make bcm2711_defconfig` | `make bcm2711_defconfig` |
| BeagleBone Black | `make bb.org_defconfig` | - |

```bash
# example: QEMU
export ARCH=arm
export CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-
make vexpress_defconfig
```

Use the same `CROSS_COMPILE` you used for U-Boot on that board.

### 3. Customise the configuration

```bash
make menuconfig
```

Apply these requirements on every board:

| Requirement | Where in menuconfig | Symbol |
|---|---|---|
| Enable **devtmpfs** (the kernel creates `/dev` nodes itself) | Device Drivers → Generic Driver Options | `DEVTMPFS=y`, `DEVTMPFS_MOUNT=y` |
| Compress the kernel with **XZ** | General setup → Kernel compression mode | `KERNEL_XZ=y` |
| Set the local version to `-<yourName>-v1.0` | General setup → Local version | `LOCALVERSION="-<yourName>-v1.0"` |

### 4. Build

```bash
# 32-bit boards
make -j$(nproc) zImage modules dtbs

# 64-bit Raspberry Pi
make -j$(nproc) Image modules dtbs
```

Find your outputs:

```bash
ls arch/${ARCH}/boot/                               # zImage or Image
find arch/${ARCH}/boot/dts -name '<your-dtb>.dtb'   # the dts folder layout differs between kernel versions
```

| Board | Device tree |
|---|---|
| QEMU vexpress-a9 | `vexpress-v2p-ca9.dtb` |
| Raspberry Pi 3 / 4 | `bcm2710-rpi-3-b.dtb` / `bcm2711-rpi-4-b.dtb` |
| BeagleBone Black | `am335x-boneblack.dtb` |

### 5. Install the modules into a staging rootfs

Modules (`.ko` files) are scattered across the source tree. `modules_install` collects them into
`/lib/modules/<kernel version>/` under a folder of your choice. That folder becomes the root filesystem in the
next lesson.

```bash
make -j$(nproc) INSTALL_MOD_PATH=$HOME/rootfs modules_install
```

### 6. Copy the kernel and device tree to the TFTP server

```bash
# 32-bit example (QEMU)
cp arch/arm/boot/zImage /srv/tftp/
cp $(find arch/arm/boot/dts -name vexpress-v2p-ca9.dtb) /srv/tftp/
```

Use your board's device tree name from the table in step 4.

### 7. Boot the kernel from U-Boot

Start the board and stop at the U-Boot prompt (QEMU: [`run-qemu-uboot.sh`](../scripts/run-qemu-uboot.sh)).

| Board | `bootargs` |
|---|---|
| QEMU vexpress-a9 | `console=ttyAMA0` |
| Raspberry Pi 3 / 4 (with `enable_uart=1`) | `console=ttyS0,115200` |
| BeagleBone Black | `console=ttyS0,115200` |

```bash
# U-Boot prompt
setenv bootargs console=ttyAMA0
saveenv

# load the kernel and the device tree into RAM
tftp ${kernel_addr_r} zImage
tftp ${fdt_addr_r} vexpress-v2p-ca9.dtb

# boot: kernel address, no initramfs (-), device tree address
bootz ${kernel_addr_r} - ${fdt_addr_r}
```

> [!NOTE]
> For a 64-bit kernel, load `Image` and use `booti` instead of `bootz`.

## Checkpoint

You should see the kernel's boot messages, your local version in the first lines, and then a **panic**:

```text
Booting Linux on physical CPU 0x0
Linux version 6.6.x-<yourName>-v1.0 ...
...
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
```

> [!TIP]
> **This panic is the expected result.** The kernel started correctly, but it has no root filesystem to mount,
> and therefore no `init` program to run. Building one is the next lesson.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Starting kernel ...` and then nothing | Wrong `console=` for the board, or wrong dtb | Check the tables in steps 4 and 7 |
| `Bad Linux ARM zImage magic!` | Wrong file, or a 64-bit `Image` with `bootz` | `zImage` + `bootz` (32-bit), `Image` + `booti` (64-bit) |
| `ERROR: Did not find a cmdline Flattened Device Tree` | dtb not loaded, or overwritten | Load it at `${fdt_addr_r}` and pass that address to `bootz` |
| Build error `openssl/opensslv.h: No such file` | Missing host package | `sudo apt install libssl-dev` |
| The version line doesn't show your name | `LOCALVERSION` not saved | Re-run `make menuconfig`, save, rebuild |

## Exercises

1. Put the U-Boot commands above in a `bootcmd` variable so the board boots the kernel automatically.
2. Run `make savedefconfig` and compare the resulting `defconfig` with the one you started from.
3. Add `loglevel=3` to `bootargs` and compare how much the kernel prints.

## Recap

- You built a kernel and device tree and booted them from U-Boot over TFTP.
- The panic tells you exactly what's missing: a **root filesystem**. That's next.
