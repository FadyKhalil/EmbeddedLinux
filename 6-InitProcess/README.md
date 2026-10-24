# 6 - Init Process

> Start your own daemon at boot (and stop it at shutdown) with BusyBox init, System V init and systemd.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1.5 hours |
| **Previous** | [5 - BusyBox root filesystem](../5-Busybox/README.md) |
| **Next** | [7 - Buildroot](../7-BuildRoot/README.md) |

## What you will learn

- What PID 1 does and how the three common init systems differ
- How to add start / stop scripts to BusyBox init via `inittab`
- How System V init scripts and runlevels work
- How to write, enable and debug a systemd service

## Prerequisites

- [Lesson 5](../5-Busybox/README.md) done, booting the rootfs over **NFS** (Option A)
- `cmake` on the host (`sudo apt install cmake`)
- For Part B and Part C you need an image that contains System V init or systemd. The easiest way is
  Buildroot from [lesson 7](../7-BuildRoot/README.md) (*System configuration → Init system*), so you can come
  back to these parts after lesson 7.

## Background

The **init process** is the first user-space process the kernel starts. It has **PID 1**, starts every other
service, adopts orphaned processes and handles shutdown.

```bash
# target shell: show the process tree with PIDs
pstree -p
```

| | BusyBox init | System V init | systemd |
|---|---|---|---|
| Config | `/etc/inittab` | `/etc/inittab` + `/etc/init.d/` scripts | Unit files in `/etc/systemd/system/` |
| Runlevels / targets | No | Runlevels 0-6 | Targets (`multi-user.target`...) |
| Size | Tiny | Small | Large |
| Typical use | Minimal systems | Classic embedded, older distros | Feature-rich devices |

The same rootfs is reused for every part: you boot it over NFS, so files you add on the host appear on the target immediately.

### Make NFS boot automatic

Save the boot commands in U-Boot once so every reboot boots the NFS rootfs (single quotes keep
`${...}` from being expanded too early):

```bash
# U-Boot prompt (use your board's console and dtb)
setenv bootargs_nfs 'setenv bootargs console=ttyAMA0 root=/dev/nfs ip=192.168.0.100:::::eth0 nfsroot=192.168.0.1:/home/<you>/rootfs,nfsvers=3,tcp rw init=/sbin/init'
setenv bootcmd_nfs 'run bootargs_nfs; tftp ${kernel_addr_r} zImage; tftp ${fdt_addr_r} <your-board>.dtb; bootz ${kernel_addr_r} - ${fdt_addr_r}'
setenv bootcmd 'run bootcmd_nfs'
saveenv
```

## Steps

### 1. Build the demo application

[`InitApp/deamonapp.c`](../InitApp/deamonapp.c) is a tiny daemon that prints a message every 4 seconds.
Cross-compile it **statically** so it doesn't need any library on the target:

```bash
cd <path-to-this-repo>/InitApp
cmake -B build -DCMAKE_C_COMPILER=${CROSS_COMPILE}gcc
cmake --build build

file build/deamonapp        # must say ARM, statically linked
sudo cp build/deamonapp $HOME/rootfs/bin/
```

### Part A - BusyBox init

#### 2. Write a start and a stop script

`$HOME/rootfs/etc/init.d/rcS1`, run at boot:

```sh
#!/bin/sh
echo "rcS1 is on"
deamonapp &
```

`$HOME/rootfs/etc/init.d/rcK1`, run at shutdown:

```sh
#!/bin/sh
echo "shutdown deamon app"
pkill -e deamonapp
sleep 3
```

```bash
sudo chmod +x $HOME/rootfs/etc/init.d/rcS1 $HOME/rootfs/etc/init.d/rcK1
```

#### 3. Call them from `inittab`

Replace `$HOME/rootfs/etc/inittab` with:

```bash
# mount proc and sys file systems
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -t sysfs sysfs /sys

# execute when the system starts
::sysinit:/etc/init.d/rcS1

# ask the user to press Enter, then start a shell
::askfirst:-/bin/sh

# execute when the system goes down
::shutdown:/etc/init.d/rcK1
```

Reboot the board. You should see `rcS1 is on` and then the daemon's message every 4 seconds.
Type `reboot` (or `poweroff`) on the target to see `rcK1` stop it.

### Part B - System V init

System V init is the classic init that BusyBox init is a trimmed-down copy of. It adds two things:
**standard start/stop scripts** that are easy to add packages to, and **runlevels**.

#### 4. Write an init script

`/etc/init.d/deamonapp`:

```sh
#!/bin/sh
case "$1" in
    start)
        echo "Starting deamonapp........."
        start-stop-daemon -S -b -n deamonapp -a /bin/deamonapp
        ;;
    stop)
        echo "Stopping deamonapp........."
        start-stop-daemon -K -n deamonapp
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
esac
exit 0
```

```bash
chmod +x /etc/init.d/deamonapp
```

`start-stop-daemon` makes background services easy to manage: `-S` starts the program (and makes sure only
one instance runs), `-b` puts it in the background, and `-K` stops it by sending `SIGTERM`.

#### 5. Try it by hand

```bash
# target shell
/etc/init.d/deamonapp            # prints the usage line
/etc/init.d/deamonapp start
ps | grep deamonapp              # running
/etc/init.d/deamonapp stop
ps | grep deamonapp              # gone
```

#### 6. Start it automatically for a runlevel

On images with runlevel folders (`/etc/rc<N>.d/`, e.g. Yocto's sysvinit), add symbolic links:

```bash
# target shell, from the rootfs root
# S = call the script with "start"; 40 = order (lower runs first)
ln -s ../init.d/deamonapp ./etc/rc5.d/S40deamonapp

# K = call it with "stop" when entering runlevel 4
ln -s ../init.d/deamonapp ./etc/rc4.d/K40deamonapp
```

```bash
# target shell
telinit 4        # switch to runlevel 4: the daemon is stopped
telinit 5        # back to runlevel 5: it starts again
```

> **Buildroot's System V init** has no `rc<N>.d` folders: its `/etc/init.d/rcS` simply runs every
> `/etc/init.d/S??*` script in order. Name your script `/etc/init.d/S40deamonapp` there instead.

### Part C - systemd

#### 7. Write a service unit

`/etc/systemd/system/deamonapp.service`:

```ini
[Unit]
Description=Demo daemon from the Embedded Linux course

[Service]
Type=simple
ExecStart=/bin/deamonapp

[Install]
WantedBy=multi-user.target
```

#### 8. Control and inspect it

```bash
# target shell
systemctl daemon-reload            # make systemd read the new file
systemctl start deamonapp
systemctl status deamonapp         # active (running)
ps | grep deamonapp                # the process is there

systemctl stop deamonapp
ps | grep deamonapp                # the process is gone

# logs (the daemon's output goes to the journal)
journalctl -u deamonapp.service
journalctl -u deamonapp.service -b # current boot only
```

#### 9. Start it at every boot

The `[Install]` section is what makes this possible:

```bash
# target shell
systemctl enable deamonapp
reboot
# after reboot:
ps | grep deamonapp                # running without starting it by hand
```

`enable` creates a link in `/etc/systemd/system/multi-user.target.wants/`. A target's `.wants` folder works
exactly like listing the service under `Wants=` in the target itself, so services can add themselves to a
target without editing it.

## Checkpoint

```text
rcS1 is on

 Deamon is up and running

Please press Enter to activate this console.
```

The message keeps repeating every 4 seconds, and stops after `rcK1` runs at shutdown.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `can't run '/etc/init.d/rcS1': Permission denied` | Script not executable | `sudo chmod +x` it on the host |
| `deamonapp: not found` | Binary missing or built for x86 | `file $HOME/rootfs/bin/deamonapp` must say ARM |
| `deamonapp: not found` although the file exists | Built dynamically, libraries missing | Rebuild; the CMake file links with `-static` |
| `telinit: not found` / no `rc5.d` | Running BusyBox init, not System V | Use a Buildroot / Yocto image with System V init |
| `systemctl: not found` | Image doesn't use systemd | Rebuild Buildroot with *Init system = systemd* |
| Service fails, `status=203/EXEC` | `ExecStart` path wrong or not executable | Check the path and `chmod +x` |

## Exercises

1. Change `deamonapp.c` to write to `/tmp/deamon.log` instead of the console, rebuild, and check the file.
2. Add `Restart=always` to the systemd unit, then `kill` the process and watch systemd restart it.
3. Make the System V script support `restart` and `status`.

## Recap

- PID 1 decides what runs at boot; you started your own daemon with three different init systems.
- Doing all of this by hand is a lot of work. Next, **Buildroot** builds the toolchain, bootloader, kernel and rootfs for you.
