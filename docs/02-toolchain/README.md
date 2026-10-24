# 2 · Cross Toolchain with Crosstool-NG

> Build your own ARM cross compiler. Every later lesson uses it to build U-Boot, the kernel, BusyBox and your apps.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi · BeagleBone Black |
| **Time** | ~20 min of work + 30-60 min build |
| **Previous** | [1 · Libraries](../01-libraries/README.md) |
| **Next** | [3 · U-Boot](../03-u-boot/README.md) |

## What you will learn

- What a cross toolchain is, and why the PC's own `gcc` can't build code for the board
- How to read a toolchain *tuple* (`arch-vendor-os-abi`)
- How to build a toolchain from a Crosstool-NG sample
- How to check that a binary was built for ARM

## Prerequisites

- Host set up as on the [home page](../index.md#host-setup)
- About 10 GB of free disk space

## Background

Your PC has an x86-64 CPU; the board has an ARM CPU. They don't understand each other's machine code.

<figure class="el-anim">
<img src="cross-compile.svg" alt="The same hello.c built with the host gcc gives an x86-64 binary; built with the cross compiler it gives an ARM binary that runs on the board">
<ol class="el-anim-steps">
<li>You start from one portable C source file, <code>hello.c</code>.</li>
<li>The PC's own <code>gcc</code> produces <b>x86-64</b> machine code. It runs on your PC, but on the board you get <code>Exec format error</code>.</li>
<li>A <b>cross compiler</b> also runs on your PC, but generates <b>ARM</b> machine code.</li>
<li>Copy that binary to the board and it runs. Everything for the board is built this way.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/02-toolchain/index.html">course website</a>.</figcaption>
</figure>

A **cross toolchain** contains the compiler (`gcc`), binutils (`as`, `ld`, `objdump`...), a C library (glibc or
musl) and the Linux kernel headers, all built for **one** target. Every tool in it is named after that target's
**tuple**:

```text
arm - cortexa9_neon - linux - gnueabihf
 |         |           |        |
arch     vendor        OS     ABI (GNU EABI, hard-float)
```

That prefix is what goes into `CROSS_COMPILE`. With `CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-`, the
kernel and U-Boot build systems call `arm-cortexa9_neon-linux-gnueabihf-gcc`.

> [!TIP]
> For Raspberry Pi and BeagleBone you can also use Ubuntu's prebuilt `gcc-arm-linux-gnueabihf` (32-bit) or
> `gcc-aarch64-linux-gnu` (64-bit). Building your own toolchain once is still worth it to see what's inside.

## Steps

### 1. Install the build dependencies

```bash
sudo apt install -y gcc g++ gperf bison flex texinfo help2man make libncurses-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch rsync
```

### 2. Get and build Crosstool-NG

```bash
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
git checkout crosstool-ng-1.26.0      # or a newer release tag

./bootstrap
./configure --enable-local            # run ct-ng from this folder, no install needed
make
```

### 3. Pick a sample for your board

```bash
# list every ready-made configuration
./ct-ng list-samples | grep arm
```

| Board | CPU | Sample |
|---|---|---|
| QEMU vexpress-a9 | Cortex-A9 | `arm-cortexa9_neon-linux-gnueabihf` |
| BeagleBone Black | Cortex-A8 | `arm-cortex_a8-linux-gnueabi` |
| Raspberry Pi 3 / 4 (32-bit) | Cortex-A53 / A72 | `armv8-rpi3-linux-gnueabihf` / `armv8-rpi4-linux-gnueabihf` |

```bash
# load the sample (QEMU example)
./ct-ng arm-cortexa9_neon-linux-gnueabihf
```

### 4. Review the configuration

```bash
./ct-ng menuconfig
```

Worth a look:

- **Paths and misc options → Prefix directory**: where the toolchain is installed (default `~/x-tools/${CT_TARGET}`).
- **C-library**: glibc (default) or musl. Switching to musl changes the tuple to `...-musleabihf`.

### 5. Build it

```bash
# build with 4 parallel jobs; this takes a while
./ct-ng build.4
```

### 6. Use it in every terminal

```bash
export PATH=$HOME/x-tools/arm-cortexa9_neon-linux-gnueabihf/bin:$PATH
export CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-
export ARCH=arm
```

The script [`setenv-cross.sh`](../scripts/setenv-cross.sh) does exactly this: run
`source docs/scripts/setenv-cross.sh` in each new terminal.

## Checkpoint

```bash
${CROSS_COMPILE}gcc --version

printf '#include <stdio.h>\nint main(void){puts("hello ARM");return 0;}\n' > hello.c
${CROSS_COMPILE}gcc hello.c -o hello
file hello
```

```text
hello: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, ...
```

If `file` says `x86-64`, you used the host `gcc` instead of the cross compiler.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `./ct-ng: No such file or directory` | `make` skipped, or wrong folder | Re-run step 2 inside `crosstool-ng/` |
| Build stops while downloading tarballs | Network or mirror problem | Re-run `./ct-ng build.4`; finished steps are cached |
| `...-gcc: command not found` | `PATH` not set in this terminal | Re-run step 6 |
| `Don't run as root` | You used `sudo` | Build as your normal user |

## Exercises

1. Build `hello.c` with `-static` and compare `file` and `ls -l` with the dynamic version.
2. Run `${CROSS_COMPILE}objdump -d hello | head -40` and spot the ARM instructions.

## Recap

- You have a cross compiler in `~/x-tools/<tuple>/` and know how to point `CROSS_COMPILE` at it.
- Next you'll use it to build the first program the board runs: **U-Boot**.
