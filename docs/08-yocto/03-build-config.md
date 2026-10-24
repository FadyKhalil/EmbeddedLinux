# 8.3 · Build Folder & Configuration Files

> Understand the variables in `local.conf` and `bblayers.conf`, and add a package to your image.

| | |
|---|---|
| **Previous** | [8.2 · What to edit](02-what-to-edit.md) |
| **Next** | [8.4 · Layers](04-layers.md) |

Both files are in `build/conf/`, created by `source poky/oe-init-build-env build`.

## `local.conf`

| Variable | Description |
|---|---|
| `MACHINE` | The board to build for. The layer that defines it must be in `bblayers.conf`. Example for BeagleBone: `meta-yocto-bsp/conf/machine/beaglebone-yocto.conf` → `MACHINE = "beaglebone-yocto"` |
| `DL_DIR` | Download folder for all source archives. Share it between builds so nothing is downloaded twice |
| `SSTATE_DIR` | Shared-state cache: already-built task outputs, so a package isn't rebuilt if nothing changed. Also shareable |
| `TMPDIR` | Where the build happens; contains `deploy/` with the final images |
| `DISTRO` | The distribution policy to use (a collection of software components and configuration that work together), `poky` by default |
| `PACKAGE_CLASSES` | Package format to produce: `package_rpm`, `package_deb` or `package_ipk` |
| `EXTRA_IMAGE_FEATURES` | Extra features for the image, e.g. `debug-tweaks` (empty root password), `tools-debug` |
| `USER_CLASSES` | Extra classes for every build, e.g. `buildstats` (records how long each task took) |
| `PATCHRESOLVE` | What to do when a patch fails: `noop` (stop the build) or `user` (open a terminal so you can fix it) |
| `BB_DISKMON_DIRS` | Disk-space monitor for `TMPDIR`, `DL_DIR` and `SSTATE_DIR`: stops the build before the disk is full |
| `CONF_VERSION` | Version of the `local.conf` format, used to detect outdated files. Don't change it |
| `INHERIT += "rm_work"` | Deletes each recipe's work folder once it's built, saving a lot of disk space |

## `bblayers.conf`

| Variable | Description |
|---|---|
| `POKY_BBLAYERS_CONF_VERSION` | Version of the `bblayers.conf` format |
| `BBLAYERS` | Every layer this build uses; recipes are only found in these layers |
| `BBPATH` | Search path BitBake uses to find `conf/` and `classes/` files |
| `BBFILES` | Recipe files to parse (normally set by each layer's `layer.conf`) |

### Manage layers with `bitbake-layers`

Prefer this over editing `BBLAYERS` by hand: it checks the layer and its dependencies.

```bash
# !!! run inside the build directory, after sourcing oe-init-build-env

bitbake-layers show-layers               # list layers and their priorities
bitbake-layers add-layer ../meta-<name>  # add a layer
bitbake-layers remove-layer meta-<name>  # remove a layer
```

## Adding a package to the image

Suppose you want Git and Python 3 in the image. First check that a recipe for it exists in your layers:

```bash
# shows which layer provides the git recipe
bitbake-layers show-recipes git
```

Then add them in `local.conf`:

```bash
# :append adds no space by itself, so start the value with a space
IMAGE_INSTALL:append = " git python3"
```

Rebuild the image (`bitbake core-image-minimal`) to apply the change.

> [!WARNING]
> Without the leading space you would get e.g. `...busyboxgit`, and the build fails with
> `Nothing RPROVIDES 'busyboxgit'`. See [variable assignment](06-variable-assignment.md).

## Exercises

1. Point `DL_DIR` and `SSTATE_DIR` to `~/yocto/downloads` and `~/yocto/sstate-cache`, so a second build folder can reuse them.
2. Add `INHERIT += "rm_work"` and compare the size of `tmp/` after a clean build.
