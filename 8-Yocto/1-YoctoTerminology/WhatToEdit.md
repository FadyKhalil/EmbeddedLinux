# Recipes

**Non-Yocto:** A recipe is a set of instructions that describe how to prepare or make something, especially a dish

**Yocto:** A recipe is a set of instructions that is read and processed by the bitbake

Extension of Recipe: 	**.bb**

A recipe describes:

-     where you get source code
-     which patches to apply
-     Configuration options
-     Compile options (library dependencies)
-     Install
-     License

**Examples of Recipes**

- dhcp_4.4.1.bb
- gstreamer1.0_1.16.1.bb

# Configuration Files

**Files which hold**
    global definition of variables
    user defined variables and
    hardware configuration information

They tell the build system what to build and put into the image to support a particular platform

- Extension:	 **.conf**


Types
--------

	• Machine Configuration Options
	• Distribution Configuration Options
	• Compiler tuning options
	• General Common Configuration Options
	• User Configuration Options (local.conf)

# Classes

Class files are used to abstract common functionality and share it **amongst multiple recipe (.bb)** files

To use a class file, you simply make sure **the recipe inherits the class**

Eg. inherit classname

- Extension: 	.**bbclass**


They are usually placed in classes directory inside the **meta*** directory

Example of classes
-------------------

- **cmake.bbclass** - Handles cmake in recipes
- **kernel.bbclass** - Handles building kernels. Contains code to build all kernel trees
- **module.bbclass** - Provides support for building out-of-tree Linux Kernel Modules

# Layers

A collection of related recipes.

or

Layers are recipe containers (folders)

Typical naming convention: **meta-<layername>**

Poky has the following layers:

meta, meta-poky, meta-selftest, meta-skeleton, meta-yocto-bsp

Why Layers
-----------

 Layers provide a mechanism to isolate meta data according to functionality, for instance BSPs, distribution configuration, etc.

You could have a BSP layer, a GUI layer, a distro configuration, middleware, or an application

Putting your entire build into one layer limits and complicates future customization and reuse. 

**Example:** 

- meta-poky          -- Distro metadata
- meta-yocto-bsp     -- BSP    metadata

Layers allow to easily to add entire sets of meta data and/or replace sets with other sets.
meta-poky, is itself a layer applied on top of the OE-Core metadata layer, meta

Command to find out which layers are present
----------------------------------------------

`$ bitbake-layers show-layers`

Note: You can include any number of available layers from the Yocto Project 

Where to get other layers
--------------------------

https://layers.openembedded.org/layerindex/branch/master/layers/

# Image

An image is the top level recipe, it has a description, a license and inherits the core-image class

It is used alongside the machine definition

machine describes the hardware used and its capabilities

image is architecture agnostic and defines how the root filesystem is built, with what packages.

By default, several images are provided in Poky

Command to check the list of available image recipes
----------------------------------------------------

```bash
`$ ls meta*/recipes*/images/*.bb`
```

# Packages

**Non-Yocto:** Any wrapped or boxed object or group of objects.

**Yocto:** A package is a binary file with name *.rpm, *.deb, or *.ipkg

A single recipe produces many packages. All packages that a recipe generated are listed in the recipe variable

```bash
$ vi  meta/recipes-multimedia/libtiff/tiff_4.0.10.bb
PACKAGES =+ "tiffxx tiff-utils"
```

