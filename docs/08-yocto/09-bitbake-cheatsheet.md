# BitBake Cheat Sheet

> All the BitBake commands you need day to day, in one place.

| | |
|---|---|
| **Previous** | [8.8 · Tasks](08-tasks.md) |
| **Back to** | [Course overview](../index.md) |

## Basic commands

| Command | Description |
|---|---|
| `bitbake <recipe>` | Run all tasks needed to build the recipe |
| `bitbake -c <task> <recipe>` | Run a specific task of the recipe |
| `bitbake -c listtasks <recipe>` | List the recipe's tasks |
| `bitbake -s` | List all recipes available in the layers of `bblayers.conf`, with versions |
| `bitbake -vDDD <recipe>` | Verbose output with maximum debug messages |
| `bitbake -c cleanall <recipe>` | Delete the recipe's work directory, shared state and downloads |
| `bitbake -c cleansstate <recipe>` | Delete the work directory and shared-state cache (keeps downloads) |
| `bitbake -c devshell <recipe>` | Open a shell in the source folder with the build environment set |
| `bitbake -e <recipe> \| grep ^<VAR>=` | Show a variable's final value in a recipe |
| `bitbake-getvar -r <recipe> <VAR>` | Same, shorter, and also shows where the value came from |

## `bitbake-layers` commands

| Command | Description |
|---|---|
| `bitbake-layers show-layers` | Show the layers in the build and their priorities |
| `bitbake-layers add-layer <path>` | Add a layer |
| `bitbake-layers remove-layer <name>` | Remove a layer |
| `bitbake-layers show-recipes <name>` | Show which layer provides a recipe |
| `bitbake-layers create-layer <path>` | Create a new layer skeleton |

## Adding files to the rootfs

A recipe that fetches a git repository and installs two extra files from the recipe's `files/` folder:

```bash
DESCRIPTION = "Install files into rootfs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# also look for files in files/ next to this recipe
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/<user>/<repo>.git;protocol=https;branch=main \
           file://file1 \
           file://file2 \
          "
SRCREV = "<commit hash>"

# git sources are unpacked into WORKDIR/git
S = "${WORKDIR}/git"

do_install:append() {
    # create the destination folder in the rootfs
    install -d ${D}${bindir}
    # file:// sources are unpacked into WORKDIR, not S
    install -m 0644 ${WORKDIR}/file1 ${D}${bindir}
    install -m 0644 ${WORKDIR}/file2 ${D}${bindir}
}
```

## Increase the filesystem size of a `.wic` / SD card image

For example, a 2 GB rootfs (size in KiB), in `local.conf`:

```bash
IMAGE_ROOTFS_SIZE = "2097152"
IMAGE_OVERHEAD_FACTOR = "1.0"
```
