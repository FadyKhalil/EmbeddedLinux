# 8.7 · Your First Recipe

> Write a recipe that compiles a C program, installs it, and puts it in your image.

| | |
|---|---|
| **Previous** | [8.6 · Variable assignment](06-variable-assignment.md) |
| **Next** | [8.8 · Tasks](08-tasks.md) |

## Prerequisites

- Your own layer from [8.4 · Layers](04-layers.md), added to the build

## Steps

### 1. Create the folder structure

```text
meta-mylayer/
└── recipes-example/
    └── helloworld/
        ├── files/
        │   └── helloworld.c
        └── helloworld_1.0.bb
```

> [!IMPORTANT]
> Use **hyphens** exactly like this: the layer's `conf/layer.conf` only searches `recipes-*/*/*.bb`, so a
> folder named `recipes_example` would be silently ignored.

### 2. Source file (`files/helloworld.c`)

```c
#include <stdio.h>

int main(void)
{
	printf("hello world!\n");
	return 0;
}
```

### 3. Recipe file (`helloworld_1.0.bb`)

```bash
# A brief description of the recipe
SUMMARY = "Hello World Program"

# License of the code: MIT, GPL-2.0-only, BSD-3-Clause, ...
LICENSE = "MIT"

# License file location and its md5 checksum
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# Source files, searched in the files/ folder next to the recipe
SRC_URI = "file://helloworld.c"

# file:// sources are unpacked into WORKDIR (scarthgap)
S = "${WORKDIR}"

# compile
do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} ${S}/helloworld.c -o ${B}/helloworld
}

# install into the package staging area
do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${B}/helloworld ${D}${bindir}/
}
```

`${bindir}` is a standard path variable meaning **`/usr/bin`**; `${sbindir}` means **`/usr/sbin`**.

> [!NOTE]
> Newer releases (Yocto 5.1 "styhead" and later) unpack `file://` sources into `${UNPACKDIR}` instead.
> There, use `S = "${UNPACKDIR}"`.

### 4. Build the recipe

```bash
bitbake helloworld
```

### 5. Add it to the image

In `conf/local.conf`:

```bash
IMAGE_INSTALL:append = " helloworld"
```

```bash
bitbake core-image-minimal
```

### How to generate the md5 checksum

```bash
# go to poky/meta
md5sum COPYING.MIT
```

### 6. A real recipe: `heartbeat` from git

`helloworld` keeps its source next to the recipe. Real recipes usually **fetch from a git repository** and build
with the project's own Makefile. Package the `heartbeat` daemon from [lesson 6](../06-init/README.md) that way, with
its init script or systemd unit:

```text
meta-mylayer/recipes-example/heartbeat/heartbeat_git.bb
```

```bash title="heartbeat_git.bb"
SUMMARY = "heartbeat demo daemon of the Embedded Linux course"
# the course repository has no license file yet; use the real one when it does
LICENSE = "CLOSED"

SRC_URI = "git://github.com/FadyKhalil/EmbeddedLinux.git;protocol=https;branch=main"
# always take the newest commit; pin a commit hash for reproducible builds
SRCREV = "${AUTOREV}"
PV = "1.0+git"

# the app lives in a sub-folder of the repository
S = "${WORKDIR}/git/docs/06-init/app"

# start it at boot with System V init (update-rc.d) or systemd, whichever the distro uses
inherit update-rc.d systemd
INITSCRIPT_NAME = "heartbeat"
INITSCRIPT_PARAMS = "defaults 40"
SYSTEMD_SERVICE:${PN} = "heartbeat.service"

# do_compile runs "oe_runmake" automatically because there's a Makefile;
# the Makefile picks up Yocto's CC, CFLAGS and LDFLAGS from the environment
do_install() {
	oe_runmake install DESTDIR=${D} PREFIX=${prefix}
	if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
		install -D -m 0644 ${S}/heartbeat.service ${D}${systemd_system_unitdir}/heartbeat.service
	else
		install -D -m 0755 ${S}/heartbeat.init ${D}${sysconfdir}/init.d/heartbeat
	fi
}
```

```bash
IMAGE_INSTALL:append = " heartbeat"     # in conf/local.conf
bitbake core-image-minimal
```

| New piece | Meaning |
|---|---|
| `git://...;protocol=https;branch=main` | Fetch with git over HTTPS, from branch `main` |
| `SRCREV` | Which commit to build; `${AUTOREV}` = latest |
| `_git.bb` + `PV = "1.0+git"` | Naming convention for recipes built from a git checkout |
| `inherit update-rc.d` | Creates the `/etc/rc<N>.d/S40heartbeat` links for you |
| `inherit systemd` | Packages and enables the unit when the distro uses systemd |
| `oe_runmake` | Runs `make` with the right cross-compilation settings |

## Checkpoint

```text
# target shell
root@qemux86-64:~# helloworld
hello world!
root@qemux86-64:~# /etc/init.d/heartbeat status
heartbeat is running (pid 211)
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Nothing PROVIDES 'helloworld'` | Recipe not found | Check folder names (`recipes-*`), and that the layer is in `bblayers.conf` |
| `LIC_FILES_CHKSUM` mismatch | Wrong md5 | Recompute it with `md5sum` |
| `No GNU_HASH in the elf binary` | `LDFLAGS` not passed to the compiler | Keep `${LDFLAGS}` in `do_compile` |
| `File ... not found` during `do_fetch` | File not in `files/` | Check the name in `SRC_URI` matches the file |

## Exercises

1. Turn `helloworld.c` into two files (`main.c` + `hello.c`) and update `SRC_URI` and `do_compile`.
2. Look at the work directory: `bitbake-getvar -r helloworld WORKDIR`, then explore `image/` inside it.
