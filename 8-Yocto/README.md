# Yocto

Yocto Project provides a flexible toolset and a development environment that allows embedded device developers across the world to collaborate through shared technologies, software stacks, configurations, and best practices used to create these tailored Linux images.

## Setting Host Environment

Need to download the following essential tool to build yocto project

```bash
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat libsdl1.2-dev xterm
```

## Download Yocto Project

1.  Create a directory called `yocto` and change directory to it.

```bash
mkdir yocto && cd yocto
```

2. Clone Poky reference and change directory to poky and checkout to stable release by poky dunfell branch

```bash
# Clone the repo
git clone -b dunfell git://git.yoctoproject.org/poky.git

# Change directory
cd poky
```

## Configuration Poky

We need to source the oe-init-build-env to set the environment for poky

```bash
source oe-init-build-env [Give folder name to be created]
```

Edit the tune of the parallelism of bitbake generator for fast execution and generation of project.

```bash
# change directory to conf
cd conf

# edit the file local.conf
vim local.com
```

Then we need to add the two line in the file

```bash
##### Please replace number of cores with your host cores and multiply it by the number next to it #####
BB_NUMBER_THREADS ?= "1.5 * Number of cores"
PARALLEL_MAKE ?= "-j 2 * Number of cores"

#### EXAMPLE #####
## my machine has 4 cores ##
BB_NUMBER_THREADS ?= "6"
PARALLEL_MAKE ?= "8"

## NUMBER OF CORES MUST BE PAIR ##
```

### Qemu build

Poky the default setting is to build qemu so we only need to run bitbake

```bash
# bitbake [options] [recipename/target ...]
bitbake core-image-minimal
```

### Raspberry Pi

We need to download the meta layer for raspberry pi

Check the following link for other meta layer required [OpenEmbedded Link](https://layers.openembedded.org/layerindex/branch/master/layers/)

Any meta data downloaded make sure to check out to **Dunfell branch**

```bash
# getting meta-raspberrypi
git clone git://git.yoctoproject.org/meta-raspberrypi
git checkout dunfell
```

We can also download of the layer that has many feature

```bash
git clone git://git.openembedded.org/meta-openembedded
git checkout dunfell
```

We need to add the layer in **bblayer.conf**

```bash
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/ahmed/Documents/linux_amit/Embedded_linux/Linux-yocto-Excersises/yocto/building_Raspberrypi_image/poky/meta \
  /home/ahmed/Documents/linux_amit/Embedded_linux/Linux-yocto-Excersises/yocto/building_Raspberrypi_image/poky/meta-poky \
  /home/ahmed/Documents/linux_amit/Embedded_linux/Linux-yocto-Excersises/yocto/building_Raspberrypi_image/poky/meta-yocto-bsp \
  /home/ahmed/Documents/linux_amit/Embedded_linux/Linux-yocto-Excersises/yocto/building_Raspberrypi_image/meta-raspberrypi \
  "
```

Change the machine in **local.conf** to the require raspberry pi chosen

```bash
...
# This sets the default machine to be qemux86-64 if no other machine is selected:
#MACHINE ??= "qemux86-64"
MACHINE = "raspberrypi<x>"
BB_NUMBER_THREADS = "6"
PARALLEL_MAKE = "-j 8"
...

```

**Build the image**

```bash
# bitbake [options] [recipename/target ...]
bitbake core-image-minimal
```

### BeagleBone

Poky has the metadata bsp data layer for beaglebone we only need to change the support machine variable in **local.conf**

```bash
# Comment the following line in local.conf
#MACHINE ??= "qemux86"
# Uncomment the following line
MACHINE = "beaglebone"
```

Now we need to add the required layer for beaglebone

```bash
# clone meta ti for beaglebone
git clone git://git.yoctoproject.org/meta-ti
```

We include the layer in **bblayer.conf**

```bash
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/ahmed/yocto-training/yocto/layers/poky/meta \
  /home/ahmed/yocto-training/yocto/layers/poky/meta-poky \
  /home/ahmed/yocto-training/yocto/layers/poky/meta-yocto-bsp \
  /home/ahmed/yocto-training/yocto/layers/meta-ti \
```

## Yocto Build SD Card

Add in **local.conf**

```bash
IMAGE_FSTYPES +="[vendor]-sdimg"
```

