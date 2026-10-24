# 8.2 - What to Edit: Recipes, Configuration, Classes, Layers, Images, Packages

> Know which kind of file to open when you want to change something in a Yocto build.

| | |
|---|---|
| **Previous** | [8.1 - Yocto terminology](README.md) |
| **Next** | [8.3 - Build folder & configuration files](../2-FolderDescription/README.md) |

## Quick reference

| I want to... | Edit a... | Extension |
|---|---|---|
| Change how one piece of software is fetched, patched, built or installed | Recipe (or a `.bbappend` to it) | `.bb` / `.bbappend` |
| Choose the board, distro, or global build settings | Configuration file | `.conf` |
| Share build logic between many recipes | Class | `.bbclass` |
| Group my recipes and configuration so they can be reused | Layer | `meta-<name>/` |
| Choose what goes into the root filesystem | Image recipe | `.bb` |

## Recipes

- **Outside Yocto:** instructions to prepare a dish.
- **In Yocto:** instructions that **BitBake** reads and processes. Extension: **`.bb`**.

A recipe describes:

- where to get the source code
- which patches to apply
- configuration options
- compile options (library dependencies)
- how to install the result
- the license

Recipe file names follow `<name>_<version>.bb`, e.g. `busybox_1.36.1.bb`.

A **`.bbappend`** file extends an existing recipe from another layer without copying it.

## Configuration files

Configuration files (**`.conf`**) hold global variable definitions, user-defined variables and hardware
configuration. They tell the build system what to build and put into the image for a particular platform.

| Type | Example |
|---|---|
| Machine configuration | `meta-yocto-bsp/conf/machine/beaglebone-yocto.conf` |
| Distribution configuration | `meta-poky/conf/distro/poky.conf` |
| Compiler tuning | `meta/conf/machine/include/arm/armv7a/tune-cortexa8.inc` |
| Layer configuration | `meta-<name>/conf/layer.conf` |
| User configuration | `build/conf/local.conf`, `build/conf/bblayers.conf` |

## Classes

Class files (**`.bbclass`**) put common functionality in one place so **many recipes** can share it.
A recipe uses a class with:

```bash
inherit classname
```

Classes usually live in the `classes/` (or `classes-recipe/`) folder of a `meta*` layer. Examples:

| Class | What it does |
|---|---|
| `cmake.bbclass` | Builds software that uses CMake |
| `kernel.bbclass` | Builds Linux kernels |
| `module.bbclass` | Builds out-of-tree Linux kernel modules |

## Layers

A **layer** is a folder that collects related recipes and configuration. Naming convention: **`meta-<layername>`**.

Poky contains these layers: `meta`, `meta-poky`, `meta-selftest`, `meta-skeleton`, `meta-yocto-bsp`.

### Why layers?

Layers keep metadata separated by purpose, for example:

- `meta-poky`: distro metadata
- `meta-yocto-bsp`: BSP metadata
- your own layer: your applications

Putting the entire build into one layer makes future customisation and reuse hard. With layers you can
add or replace whole sets of metadata at once. `meta-poky` itself is a layer on top of the OE-Core layer `meta`.

```bash
# which layers does my build use?
bitbake-layers show-layers
```

Find more layers in the [OpenEmbedded layer index](https://layers.openembedded.org/layerindex/branch/master/layers/).
Layer creation is covered in [8.4 - Layers](../3-Layer/README.md).

## Images

An **image** is the top-level recipe: it has a description and a license, and inherits the `core-image` class.

- The **machine** describes the hardware and its capabilities.
- The **image** is architecture-independent and defines *what* goes into the root filesystem.

```bash
# list the image recipes Poky provides (run inside poky/)
ls meta*/recipes*/images/*.bb
```

## Packages

- **Outside Yocto:** a wrapped object.
- **In Yocto:** a binary file such as `*.rpm`, `*.deb` or `*.ipk` that gets installed into the image.

A single recipe can produce **several** packages. They are listed in the recipe's `PACKAGES` variable, e.g.
the `tiff` recipe adds extra ones:

```bash
# meta/recipes-multimedia/libtiff/tiff_<version>.bb
PACKAGES =+ "tiffxx tiff-utils"
```

## Exercises

1. Open `meta-yocto-bsp/conf/machine/beaglebone-yocto.conf` and find the kernel image type and the serial console.
2. Find a recipe that uses `inherit cmake` with `grep -rl "inherit cmake" meta/recipes-*`.
