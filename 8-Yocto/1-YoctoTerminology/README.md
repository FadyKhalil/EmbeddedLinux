# POKY

Poky is a reference distribution of Yocto Project. The word "reference" is used to mean "example" in this context.

Yocto Project uses Poky to build images (kernel, system, and application software) for targeted hardware.

At the technical level it is a combined repository of the components
	• Bitbake
	• OpenEmbedded Core
	• meta-yocto-bsp
	• Documentation

Note: Poky does not contain binary files,it is a working example of how to build your own custom Linux distribution from source.

What is difference between poky and Yocto
-----------------------------------------

The exact difference between Yocto and Poky is Yocto refers to the organization ( like one would refer to 'canonical', the company behind Ubuntu ), and Poky refers to the actual bits downloaded ( analogous to 'Ubuntu' )

# Metadata

**Non Yocto:**  A set of data that describes and gives information about other data

**Yocto World:** 
	Metadata refers to the build instructions, Commands and data used to indicate what versions of software are used Where they are obtained from Changes or additions to the software itself ( patches ) which are used to fix bugs or customize the software for use in a particular situation

Metadata is collection of

- ​	Configuration files (.conf)
- ​	Recipes (.bb and .bbappend)
- ​	Classes (.bbclass)
- ​	Includes (.inc)

# OpenEmbedded Project

From http://www.openembedded.org/wiki/Main_Page

OpenEmbedded offers a best-in-class cross-compile environment. It allows developers to create a complete Linux Distribution for embedded systems.

What is the difference between OpenEmbedded and the Yocto Project?
------------------------------------------------------------------

The Yocto Project and OpenEmbedded share a core collection of **metadata** called **openembedded-core.** 

However, the two organizations remain separate, each with its own focus

**OpenEmbedded** provides a comprehensive set of metadata for a wide variety of architectures, features, and applications

	Not a reference distribution
	Designed to be the foundation for others

The **Yocto** Project focuses on providing powerful, easy-to-use, interoperable, well-tested tools, metadata, and board support packages (BSPs) for a core set of architectures and specific boards.


OpenEmbedded-Core(oe-core)
---------------------------

The Yocto Project and OpenEmbedded have agreed to work together and share a common core set of metadata(recipes, classes and associated files): oe-core

# Bitbake

- Bitbake is a core component of the Yocto Project.


- It basically performs the same functionality as of **make**.


- It's a task scheduler that parses **python** and **shell** **script** mixed code


- The code parsed generates and runs **tasks**, which are basically a set of steps ordered according to code's dependencies.


- It reads recipes and follows them by fetching packages, building them and incorporating the results into bootable images.


- It keeps track of all tasks being processed in order to ensure completion, maximizing the use of processing resources to reduce build time and being predictable.

# meta-yocto-bsp

A Board Support Package (BSP) is a collection of information that defines how to support a particular **hardware device**, **set of devices**, or **hardware platform**

The BSP includes information about the hardware features present on the device and kernel configuration information along with any additional hardware drivers required.

The BSP also lists any additional software components required in addition to a generic Linux software stack for both essential and optional platform features.

The meta-yocto-bsp layer in Poky maintains several BSPs such as the Beaglebone, EdgeRouter, and generic versions of both 32-bit and 64-bit IA machines.

Machines supported
-------------------
Texas Instruments BeagleBone (beaglebone)
Freescale MPC8315E-RDB (mpc8315e-rdb)
Intel x86-based PCs and devices (genericx86 and genericx86-64)
Ubiquiti Networks EdgeRouter Lite (edgerouter)

Note: To develop on different hardware, you will need to complement Poky with hardware-specific Yocto layers.

# meta-poky

meta-poky, which is Poky-specific metadata

Documentation, which contains the Yocto Project source files used to make the set of user manuals.

# Conclusion

**Poky includes** 
	some OE components(oe-core)
	bitbake
	demo-BSP's
	helper scripts to setup environment
	emulator QEMU to test the image