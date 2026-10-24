# 6 · Init Process

> Build `heartbeat`, the course's demo daemon, and have it started at boot and stopped at shutdown by BusyBox init, System V init and systemd.

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi 3 / 4 · BeagleBone Black |
| **Time** | ~1.5 hours |
| **Previous** | [5 · Root filesystem](../05-rootfs/README.md) |
| **Next** | [7 · Buildroot](../07-buildroot/README.md) |

## What you will learn

- What PID 1 does, and how the three common init systems differ
- How init scripts start and stop a daemon, and why the daemon must handle `SIGTERM`
- How System V runlevels work
- How to write, enable and debug a systemd service

## Prerequisites

- [Lesson 5](../05-rootfs/README.md) done, booting the rootfs over **NFS** (Option A)
- For Part B and Part C you need an image with System V init or systemd. The easiest way is Buildroot
  ([lesson 7](../07-buildroot/README.md), *System configuration → Init system*), so you can come back to them after lesson 7.

## Background

The **init process** is the first user-space process the kernel starts. It has **PID 1**: it starts every other
service, adopts orphaned processes, and handles shutdown.

<figure class="el-anim">
<img src="init-lifecycle.svg" alt="The kernel starts init, init reads inittab, starts heartbeat and a shell; at reboot it runs the stop script, which sends SIGTERM and heartbeat exits cleanly">
<ol class="el-anim-steps">
<li>The kernel starts <code>/sbin/init</code> as process <b>1</b>.</li>
<li>BusyBox init reads <code>/etc/inittab</code> from top to bottom.</li>
<li><code>sysinit</code> entries run once at boot. Here the init script starts <code>heartbeat</code> in the background, and it starts printing beats on the console.</li>
<li><code>askfirst</code> starts a shell on the console after you press Enter.</li>
<li>You type <code>reboot</code>. Init now runs the <code>shutdown</code> entries.</li>
<li>The stop script sends <code>SIGTERM</code> to <code>heartbeat</code>: a polite request to stop.</li>
<li><code>heartbeat</code> catches the signal, prints a goodbye and exits cleanly. A daemon that ignored it would be killed by force a few seconds later.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/06-init/index.html">course website</a>.</figcaption>
</figure>

| | BusyBox init | System V init | systemd |
|---|---|---|---|
| Configuration | `/etc/inittab` | `/etc/inittab` + `/etc/init.d/` scripts | Unit files in `/etc/systemd/system/` |
| Runlevels / targets | No | Runlevels 0-6 | Targets (`multi-user.target`...) |
| Size | Tiny | Small | Large |
| Typical use | Minimal systems | Classic embedded systems | Feature-rich devices |

```bash
# target shell: show the process tree with PIDs
pstree -p
```

## The demo app: `heartbeat`

Everything for the app is in [`app/`](https://github.com/FadyKhalil/EmbeddedLinux/tree/main/docs/06-init/app):

| File | What it is |
|---|---|
| [`heartbeat.c`](app/heartbeat.c) | Prints a numbered, timestamped beat every 4 s; exits cleanly on `SIGTERM` / `SIGINT`. Options: `-i <seconds>`, `-p <pidfile>` |
| [`Makefile`](app/Makefile) | Builds with `CROSS_COMPILE`, links statically, `make install DESTDIR=...` |
| [`CMakeLists.txt`](app/CMakeLists.txt) | The same with CMake (see [Cross-compiling with CMake](../extras/cmake/06-cross-compiling.md)) |
| [`heartbeat.init`](app/heartbeat.init) | Start / stop script for BusyBox init and System V init |
| [`heartbeat.service`](app/heartbeat.service) | Unit file for systemd |

The part that matters for init is the signal handling:

```c title="heartbeat.c (excerpt)"
static volatile sig_atomic_t running = 1;

static void on_stop_signal(int sig)
{
	(void)sig;
	running = 0;          /* leave the main loop, clean up, exit 0 */
}
...
	sigaction(SIGTERM, &sa, NULL);   /* sent by init scripts and systemd */
	sigaction(SIGINT, &sa, NULL);    /* Ctrl+C */
```

You'll reuse this same app in [lesson 7](../07-buildroot/README.md) (as a Buildroot package) and
[lesson 8](../08-yocto/07-first-recipe.md) (as a Yocto recipe).

### Make NFS boot automatic

Save the boot commands in U-Boot once, so every reboot boots the NFS rootfs. The single quotes stop `${...}` from
being expanded too early:

```bash
# U-Boot prompt (use your board's console and dtb)
setenv bootargs_nfs 'setenv bootargs console=ttyAMA0 root=/dev/nfs ip=192.168.0.100:::::eth0 nfsroot=192.168.0.1:/home/<you>/rootfs,nfsvers=3,tcp rw init=/sbin/init'
setenv bootcmd_nfs 'run bootargs_nfs; tftp ${kernel_addr_r} zImage; tftp ${fdt_addr_r} <your-board>.dtb; bootz ${kernel_addr_r} - ${fdt_addr_r}'
setenv bootcmd 'run bootcmd_nfs'
saveenv
```

## Steps

### 1. Build heartbeat

```bash
cd <path-to-this-repo>/docs/06-init/app
make CROSS_COMPILE=${CROSS_COMPILE}

file heartbeat                         # must say ARM, statically linked
sudo make install DESTDIR=$HOME/rootfs # -> $HOME/rootfs/usr/bin/heartbeat
```

> [!TIP]
> Try it on your PC first: `make clean && make && ./heartbeat -i 1`, then press <kbd>Ctrl</kbd>+<kbd>C</kbd> and
> watch the clean exit. Run `make clean` again before cross-compiling.

### Part A · BusyBox init

#### 2. Install the init script

```bash
sudo install -m 0755 heartbeat.init $HOME/rootfs/etc/init.d/heartbeat
```

The script starts `heartbeat` in the background with its output on the console, and saves its PID so `stop` knows
which process to signal:

```sh title="heartbeat.init (excerpt)"
start)
	$DAEMON -p $PIDFILE > /dev/console 2>&1 &
	;;
stop)
	[ -f $PIDFILE ] && kill "$(cat $PIDFILE)"     # kill sends SIGTERM by default
	;;
```

#### 3. Call it from `inittab`

Replace `$HOME/rootfs/etc/inittab` with:

```bash title="$HOME/rootfs/etc/inittab"
# mount /proc and /sys (script from lesson 5)
::sysinit:/etc/init.d/rcS
# start the daemon at boot
::sysinit:/etc/init.d/heartbeat start

# ask the user to press Enter, then start a shell
::askfirst:-/bin/sh
::restart:/sbin/init

# stop the daemon, then unmount everything, when the system goes down
::shutdown:/etc/init.d/heartbeat stop
::shutdown:/bin/umount -a -r
```

#### 4. Try it

Reboot the board. You'll see `Starting heartbeat...` and then a beat every 4 seconds. Then on the target:

```bash
# target shell
/etc/init.d/heartbeat status
/etc/init.d/heartbeat stop
/etc/init.d/heartbeat start
reboot                          # watch the stop message during shutdown
```

### Part B · System V init

System V init is the classic init that BusyBox init is a trimmed-down copy of. It adds **standard start/stop
scripts** for every service, and **runlevels**. The same `heartbeat.init` script works unchanged.

#### 5. Start it at boot

**Buildroot with System V init:** Buildroot's `/etc/init.d/rcS` runs every `/etc/init.d/S??*` script with `start` at boot, in order, and
`/etc/init.d/rcK` runs them with `stop` at shutdown. The number sets the order:

```bash
# target shell (or in a Buildroot rootfs overlay)
cp heartbeat.init /etc/init.d/S40heartbeat
chmod +x /etc/init.d/S40heartbeat
```

**Images with runlevel folders** (`/etc/rc<N>.d/`, e.g. Yocto with sysvinit): add symbolic links instead:

```bash
# target shell
cp heartbeat.init /etc/init.d/heartbeat

# S = call the script with "start"; 40 = order (lower runs first)
ln -s ../init.d/heartbeat /etc/rc5.d/S40heartbeat
# K = call it with "stop" when entering runlevel 4
ln -s ../init.d/heartbeat /etc/rc4.d/K40heartbeat

telinit 4        # switch to runlevel 4: heartbeat is stopped
telinit 5        # back to runlevel 5: it starts again
```

### Part C · systemd

#### 6. Install the unit file

```ini title="/etc/systemd/system/heartbeat.service"
[Unit]
Description=heartbeat demo daemon (Embedded Linux course)

[Service]
Type=simple
ExecStart=/usr/bin/heartbeat
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

There's no start or stop script: systemd starts `ExecStart` itself, and stops the service by sending `SIGTERM`, which
`heartbeat` already handles.

#### 7. Control and inspect it

```bash
# target shell
systemctl daemon-reload            # make systemd read the new file
systemctl start heartbeat
systemctl status heartbeat         # active (running), with the latest beats
systemctl stop heartbeat

journalctl -u heartbeat            # all its output (stdout goes to the journal)
journalctl -u heartbeat -b         # current boot only
journalctl -u heartbeat -f         # follow live
```

#### 8. Start it at every boot

```bash
# target shell
systemctl enable heartbeat
reboot
# after the reboot:
systemctl status heartbeat         # running without starting it by hand
```

`enable` uses the `[Install]` section: it creates a link in `/etc/systemd/system/multi-user.target.wants/`. A
target's `.wants` folder works exactly like listing the service under `Wants=` in the target, so a service can add
itself to a target without editing it.

## Checkpoint

```text
Starting heartbeat...
heartbeat: started (pid 57), one beat every 4 s
heartbeat: beat #1 at 10:42:03

Please press Enter to activate this console.
heartbeat: beat #2 at 10:42:07
```

And at shutdown:

```text
Stopping heartbeat...
heartbeat: stop signal received, exiting cleanly after 12 beats
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `can't run '/etc/init.d/heartbeat': Permission denied` | Script not executable | `sudo chmod +x` it on the host |
| `heartbeat: not found` | Binary missing, or built for x86 | `file $HOME/rootfs/usr/bin/heartbeat` must say ARM |
| `heartbeat: not found` although the file exists | Built dynamically, libraries missing | Rebuild with the Makefile (it links with `-static`) |
| No beats on the console | Output not redirected to the console | Use the provided `heartbeat.init`, which writes to `/dev/console` |
| `telinit: not found` / no `rc5.d` | Running BusyBox init, not System V | Use a Buildroot / Yocto image with System V init |
| Service fails, `status=203/EXEC` | `ExecStart` path wrong, or not executable | Check the path and `chmod +x` |

## Exercises

1. Start `heartbeat` with `-i 1` from the init script and check the faster beat.
2. Add `Restart=always` to the unit, `kill -9` the process, and watch systemd restart it (`journalctl -f`).
3. Make the daemon ignore `SIGTERM` (comment out the `sigaction` lines), rebuild, and see how long `systemctl stop` takes now.

## Recap

- PID 1 decides what runs at boot. You started and stopped your own daemon with three different init systems.
- Doing all of this by hand is a lot of work. Next, **Buildroot** builds the toolchain, bootloader, kernel and rootfs, and `heartbeat`, for you.
