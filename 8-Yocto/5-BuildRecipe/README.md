# 8.7 - Your First Recipe

> Write a recipe that compiles a C program, installs it, and puts it in your image.

| | |
|---|---|
| **Previous** | [8.6 - Variable assignment](../4-Variables/Variable_Assignment.md) |
| **Next** | [8.8 - Tasks](../6-TaskBuild/README.md) |

## Prerequisites

- Your own layer from [8.4 - Layers](../3-Layer/README.md), added to the build

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

## Checkpoint

```text
# target shell
root@qemux86-64:~# helloworld
hello world!
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
