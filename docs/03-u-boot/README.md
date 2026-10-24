# 3 · U-Boot

> Build the bootloader, prepare an SD card, and use U-Boot to load files from the SD card and the network.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1.5 hours |
| **Previous** | [2 · Cross toolchain](../02-toolchain/README.md) |
| **Next** | [4 · Linux kernel](../04-kernel/README.md) |

## What you will learn

- How to configure and build U-Boot for a specific board
- How to partition and format an SD card (real or emulated) for booting
- How to set up a TFTP server and load files into RAM from U-Boot
- How to use U-Boot environment variables and write small scripts

## Prerequisites

- The cross toolchain from [lesson 2](../02-toolchain/README.md), with `CROSS_COMPILE` and `ARCH` exported
- Host packages from the [home page](../index.md#host-setup) (`qemu-system-arm`, `tftpd-hpa`)
- Real hardware only: a microSD card and a USB-to-serial cable

## Background

**U-Boot** is the most popular bootloader for Linux-based embedded devices (GPLv2; supports ARM, RISC-V, MIPS,
PowerPC, x86...). Its job: initialise RAM and the basic peripherals, then **load the kernel and device tree into
RAM and start the kernel**. It can fetch those files from many places.

<figure class="el-anim">
<img src="uboot-sources.svg" alt="The SoC ROM loads the first stage and U-Boot from the SD card's FAT partition; U-Boot keeps its environment there and loads files into RAM over TFTP or from the SD card">
<ol class="el-anim-steps">
<li>The SoC's <b>ROM code</b> looks at the SD card's first (FAT) partition and loads the first-stage loader: <code>MLO</code> on the BeagleBone, <code>bootcode.bin</code> on the Raspberry Pi 3.</li>
<li>The first stage loads <b>U-Boot</b> itself (<code>u-boot.img</code> / <code>u-boot.bin</code>). You get the <code>=&gt;</code> prompt. (QEMU skips both steps: it loads U-Boot directly.)</li>
<li>U-Boot reads and writes its <b>environment</b> (IP addresses, boot commands...) in <code>uboot.env</code> on the same FAT partition. That's what <code>saveenv</code> does once you configure it in step 3.</li>
<li>With <code>tftp</code>, U-Boot downloads files from your PC over the <b>network</b> straight into RAM. This is the fastest way to try a new kernel.</li>
<li>With <code>fatload</code>, it reads them from the <b>SD card</b> instead, which is how a finished product boots.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/03-u-boot/index.html">course website</a>.</figcaption>
</figure>

## Steps

### 1. Download U-Boot

```bash
git clone https://github.com/u-boot/u-boot.git
cd u-boot/
git checkout v2022.07
```

### 2. Load the default configuration for your board

```bash
# find the configurations available for your machine
ls configs/ | grep <your machine>
```

#### QEMU (vexpress Cortex-A9)

```bash
# toolchain from lesson 2
export CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-
export ARCH=arm

make vexpress_ca9x4_defconfig
```

#### Raspberry Pi

```bash
# Ubuntu's prebuilt compilers
sudo apt-get install gcc-arm-linux-gnueabihf     # 32-bit
sudo apt-get install gcc-aarch64-linux-gnu       # 64-bit
```

| Board | 32-bit (`CROSS_COMPILE=arm-linux-gnueabihf-`) | 64-bit (`CROSS_COMPILE=aarch64-linux-gnu-`) |
|---|---|---|
| Raspberry Pi 3 | `make rpi_3_32b_defconfig` | `make rpi_3_defconfig` |
| Raspberry Pi 4 | `make rpi_4_32b_defconfig` | `make rpi_4_defconfig` |

```bash
# example: Raspberry Pi 4, 32-bit
export CROSS_COMPILE=arm-linux-gnueabihf-
make rpi_4_32b_defconfig
```

#### BeagleBone Black (Cortex-A8)

```bash
export CROSS_COMPILE=arm-linux-gnueabihf-     # or the cortex_a8 toolchain from lesson 2
export ARCH=arm

make am335x_evm_defconfig
```

### 3. Customise the configuration

```bash
make menuconfig
```

Apply these requirements (press <kbd>/</kbd> in menuconfig to search for a symbol):

| Requirement | Kconfig symbol |
|---|---|
| Support the `editenv` command | `CMD_EDITENV=y` |
| Support the `bootd` command | `CMD_BOOTD=y` |
| Do **not** store the environment in flash | `ENV_IS_IN_FLASH=n` |
| Store the environment in a FAT filesystem | `ENV_IS_IN_FAT=y` |
| ...on the `mmc` interface | `ENV_FAT_INTERFACE="mmc"` |
| ...on device 0, partition 1 | `ENV_FAT_DEVICE_AND_PART="0:1"` |
| ...in a file called `uboot.env` | `ENV_FAT_FILE="uboot.env"` |

### 4. Build U-Boot

```bash
make -j$(nproc)
```

| Board | Files you'll use |
|---|---|
| QEMU | `u-boot` (ELF, given to QEMU with `-kernel`) |
| Raspberry Pi | `u-boot.bin` |
| BeagleBone Black | `MLO` and `u-boot.img` |

### 5. Prepare the SD card

The card needs two partitions: a FAT boot partition (where U-Boot looks for files and `uboot.env`) and a Linux
partition for the root filesystem in lesson 5.

| Partition | Size | Format | Bootable |
|:---:|:---:|:---:|:---:|
| 1 | `200 MB` | `FAT16` | Yes |
| 2 | rest | `Linux (ext4)` | No |

#### QEMU: create a virtual SD card

```bash
# go back next to the u-boot folder
cd ..

# 1 GB file filled with zeros (QEMU needs a power-of-2 size)
dd if=/dev/zero of=sd.img bs=1M count=1024

# attach it to a loop device so it behaves like a disk; note the device it prints
sudo losetup -f --show --partscan sd.img
export DISK=/dev/loop<x>
```

#### Real hardware: find your SD card

```bash
# plug in the card, then identify it by its size
lsblk
export DISK=/dev/mmcblk<x>      # or /dev/sd<x> on a USB card reader
```

#### Partition and format (both cases)

> [!CAUTION]
> The next commands **erase the whole drive** in `DISK`. Check it with `lsblk` first: choosing your PC's own
> disk by mistake destroys your data.

The quick way is the helper script ([`format-sd.sh`](../scripts/format-sd.sh)), which asks for confirmation:

```bash
# give the name without /dev, e.g. loop0 or mmcblk0
<path-to-this-repo>/docs/scripts/format-sd.sh loop<x>
```

Or by hand:

```bash
# create the partition table: choose "dos", make the two partitions, set bootable, Write
sudo cfdisk ${DISK}

# format partition 1 as FAT16 and partition 2 as ext4
sudo mkfs.vfat -F 16 -n boot ${DISK}p1
sudo mkfs.ext4 -L rootfs ${DISK}p2
```

> [!NOTE]
> On a USB card reader the partitions are `/dev/sdb1` and `/dev/sdb2` (no `p`).

### 6. Copy the boot files and start U-Boot

#### QEMU

Nothing to copy: QEMU loads U-Boot directly.

```bash
qemu-system-arm -M vexpress-a9 -m 128M -nographic \
    -kernel u-boot/u-boot \
    -sd sd.img
```

Press <kbd>Ctrl</kbd>+<kbd>A</kbd> then <kbd>X</kbd> to quit QEMU.

#### Raspberry Pi

Copy the Raspberry Pi firmware (closed source, from the `boot/` folder of
[raspberrypi/firmware](https://github.com/raspberrypi/firmware/tree/master/boot)) and U-Boot to the FAT partition:

| File | Pi 3 | Pi 4 |
|---|---|---|
| First-stage loader | `bootcode.bin` | *(in EEPROM, not needed)* |
| GPU firmware | `start.elf`, `fixup.dat` | `start4.elf`, `fixup4.dat` |
| Device tree | `bcm2710-rpi-3-b.dtb` | `bcm2711-rpi-4-b.dtb` |
| Bootloader | `u-boot.bin` | `u-boot.bin` |

Create `config.txt` on the same partition:

```ini
kernel=u-boot.bin
enable_uart=1
# for a 64-bit U-Boot add:
# arm_64bit=1
```

#### BeagleBone Black

Copy `MLO` and `u-boot.img` to the FAT partition. Hold the **S2 (BOOT)** button while powering on, so the board
boots from the SD card instead of its internal eMMC.

### 7. Set up a TFTP server on the host

TFTP lets U-Boot download files (kernel, device tree) from your PC: much faster than rewriting the SD card for every test.

```bash
sudo apt-get install tftpd-hpa
sudo nano /etc/default/tftpd-hpa
```

Make the file look like this:

```bash title="/etc/default/tftpd-hpa"
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure --create"
```

```bash
sudo mkdir -p /srv/tftp
sudo chown tftp:tftp /srv/tftp
sudo systemctl restart tftpd-hpa
systemctl status tftpd-hpa        # should say "active (running)"

# a file to test with
echo "hello from host" | sudo tee /srv/tftp/test.txt
```

#### QEMU only: a virtual network cable

QEMU connects the board to a TAP interface on the host. The script [`qemu-ifup`](../scripts/qemu-ifup) gives the
host side the address `192.168.0.1`:

```bash title="docs/scripts/qemu-ifup"
#!/bin/sh
ip a add 192.168.0.1/24 dev $1
ip link set $1 up
```

Start QEMU with networking, or simply run [`run-qemu-uboot.sh`](../scripts/run-qemu-uboot.sh):

```bash
sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic \
    -kernel u-boot/u-boot \
    -sd sd.img \
    -net tap,script=<path-to-this-repo>/docs/scripts/qemu-ifup -net nic
```

On real hardware, connect the board's Ethernet port to your PC (directly or through a switch) and give your PC's
interface a static IP such as `192.168.0.1`.

### 8. Configure the network in U-Boot

```bash
# U-Boot prompt
setenv ipaddr 192.168.0.100      # the board
setenv serverip 192.168.0.1      # your PC (TFTP server)
saveenv                          # written to uboot.env on the FAT partition
ping ${serverip}
```

Both addresses must be in the same subnet.

### 9. Load files into RAM

```bash
# U-Boot prompt
bdinfo                            # board information, including where RAM starts
printenv kernel_addr_r fdt_addr_r # safe load addresses defined for your board
```

From the SD card (FAT partition = device `0`, partition `1`):

```bash
# U-Boot prompt
fatls mmc 0:1
fatload mmc 0:1 ${kernel_addr_r} <fileName>
```

From the TFTP server:

```bash
# U-Boot prompt
tftp ${kernel_addr_r} test.txt
md.b ${kernel_addr_r} 0x10        # dump the first 16 bytes you just loaded
```

### 10. Write a script in U-Boot

U-Boot variables can hold commands, including `if` / `then` / `else`:

```bash
# U-Boot prompt
setenv ifcondition "if mmc dev; then echo MmcExist; elif mtd list; then echo NorFlashExist; else echo NoDeviceExist; fi"
run ifcondition
```

| Part | Meaning |
|---|---|
| `setenv ifcondition "..."` | Create a variable called `ifcondition` holding the script |
| `if mmc dev` | First condition: is an MMC/SD device available? |
| `then echo MmcExist` | Runs when the condition succeeds |
| `elif mtd list` | Otherwise: is any NOR flash supported? |
| `else echo NoDeviceExist` | Runs when neither condition succeeds |
| `fi` | Ends the condition (same as a shell script) |
| `run ifcondition` | Execute the script stored in the variable |

## Checkpoint

```text
U-Boot 2022.07 (...)
...
Hit any key to stop autoboot:  0
=>
```

- `saveenv` prints `Saving Environment to FAT... OK`.
- `tftp ${kernel_addr_r} test.txt` prints `Bytes transferred = 16`.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Nothing on the serial console (HW) | TX/RX swapped, wrong baud rate, or `enable_uart=1` missing (Pi) | Use 115200 8N1, swap TX/RX, check `config.txt` |
| `Saving Environment to Flash...` | Step 3 not applied | Re-run `make menuconfig`, set `ENV_IS_IN_FAT`, rebuild |
| `** Unable to use mmc 0:1 for saveenv **` | Partition 1 is not FAT | Re-format it with `mkfs.vfat -F 16` |
| `TFTP error: 'File not found'` | File not in `/srv/tftp`, or wrong name | `ls /srv/tftp`; names are case-sensitive |
| `Retry count exceeded` / `T T T` | Network not reachable | Check `ipaddr` / `serverip` and the host IP (`ip a`) |
| BeagleBone still boots its old system | Booting from eMMC | Hold S2 while powering on |
| No `p1` / `p2` for the loop device | Partition table not re-read | `sudo partprobe ${DISK}` |

## Exercises

1. Write a variable `bootfromtftp` that sets the IP addresses and loads `test.txt` over TFTP, then `run` it.
2. Set `bootdelay` to 5 seconds, `saveenv`, and reboot to see the effect.
3. Use `editenv` to change `serverip` interactively.

## Recap

- You built U-Boot, prepared a two-partition SD card, and loaded files into RAM over SD and TFTP.
- Next you'll build what U-Boot is really meant to load: the **Linux kernel** and its device tree.
