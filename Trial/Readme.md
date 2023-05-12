# cross compiling linux

## downloading linux

- downloading linux from git and checkout a **stable** version -> linus **torvalds** tree

```sh
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux
git checkout v5.19.6
```

## setup cross-compiling environment

```sh
export PATH=$HOME/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/bin/:$PATH
export CROSS_COMPILE=arm-cortexa9_neon-linux-uclibcgnueabihf-
export ARCH=arm
```



## cross compile the kernel for Cortex-A9

We need to compile for QEMU ARM Versatile Express for Cortex-A9

- in arch/arm/configs -> vexpress_defconfig

  ```sh
      make vexpress_defconfig
  ```

- to visualize configurations 

  ```sh
  make xconfig
  ```

  - add `CONFIG_DEVTMPFS_MOUNT` to your configuration.
    - [`devtmpfs`](http://lwn.net/Articles/330985/) is a file system with automated device nodes populated by the kernel. 
    -  let the kernel populates the appropriate information based on the known devices.
  - change kernel compression from Gzip to XZ

- need to install those packages

  ```sh 
  sudo apt install libssl-dev
  sudo apt install libgmp3-dev
  sudo apt install libmpc-dev
  ```

- `make -j8` to build

  > ...
  >
  >   OBJCOPY arch/arm/boot/zImage
  >   Kernel: arch/arm/boot/zImage is ready

  output of the kernel here is:

  - kernel image, `arch/arm/boot/zImage`
  - .dtb -> compiled DTS, `arch/arm/boot/dts/*-ca9.dtb`

  

  

  NOTE: you can also generate **.ko** **modules** build and  install it using `make modules && make modules_install` then transfer it to target and load it using:

  - `insmod` load modules without dependencies
  - `modprobe` load modules with all dependencies of top modules
  - `lsmod` display the list of loaded modules  
  - `modinfo` get information about a module without loading it: parameters, license, description and dependencies
  - `rmmod` tries to remove the given module, `modprobe -r` tries to remove the given top module and its no longer needed dependencies 
  - module parameters -> `/sys/module/\<name>/parameters`
  - dependencies described in ->  `/lib/modules/<kernel-version>/modules.dep`  


## use u-boot to download and boot the kernel

### booting kernel with UBOOT Information:

- Uboot has an important variable that is passed to kernel `bootargs`
  - This variable carry **kernel command line**, which is parameters passed to kernel before starting to allow runtime configuration
    - parameters is saved in  a chosen section in Device Tree
    
    - a list of parameters can be found [here](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html), or in **Documentation/kernel-parameters.txt**
    
    - a shortlist of most useful ones
    
      **debug**: Sets the console log level to the highest level, 8, to ensure that you see all the kernel messages on the console.
      **init=**: The init program to run from a mounted root filesystem, which defaults to /sbin/init.
      **lpj=**: Sets loops_per_jiffy to a given constant. There is a description of the significance of this in the paragraph following this list.
      **panic=**: Behavior when the kernel panics: if it is greater than zero, it gives the number of seconds before rebooting; if it is zero, it waits forever (this is the default); or if it is less than zero, it reboots without any delay.
      **quiet**: Sets the console log level to silent, suppressing all but emergency messages. Since most devices have a serial console, it takes time to output all those strings. Consequently, reducing the number of messages using this option reduces boot time.
      **rdinit=**: The init program to run from a ramdisk. It defaults to /init.
      **ro**: Mounts the root device as read-only. Has no effect on a ramdisk, which is always read/write.
      **root=**: The device on which to mount the root filesystem.
      **rootdelay=**: The number of seconds to wait before trying to mount the root device; defaults to zero. Useful if the device takes time to probe the hardware, but also see rootwait.
      **rootfstype=**: The filesystem type for the root device. In many cases, it is auto-detected during mount, but it is required for jffs2 filesystems.
      **rootwait**: Waits indefinitely for the root device to be detected. Usually **necessary** with **MMC** devices.
      **rw**: Mounts the root device as read-write (default).
    
      **ip=**: set target ip address, See **Documentation/admin-guide/nfs/nfsroot.rst**.
    
      **nfsroot=**: NFS server details
  
- U-boot can directly boot the zImage binary, typical process is to
  - load kernel (zImage) at address X in memory
  - load \<board>.dtb at address Y in memory
  - Start kernel with `bootz X - Y`
    - `-` indicates no **initramfs**



### practical

- copy image + dtb to `tftp` default directory 

  ```sh
  cp linux/arch/arm/boot/zImage /srv/tftp/
  cp linux/arch/arm/boot/dts/*-ca9.dtb /srv/tftp/
  ```

- start uboot

  ```sh
  sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel u-boot -sd sd.img -net tap,script=./qemu-ifup -net nic
  ```

- steps to boot kernel from uboot

  - set `bootargs` env

    ```sh 
    setenv bootargs console=ttyAMA0
    saveenv
    ```
  
  - load kernel image `zImage` and DTB `vexpress-v2p-ca9.dtb` from TFTP into RAM
  
    ```sh
    tftp 0x61000000 zImage
    tftp 0x62000000 vexpress-v2p-ca9.dtb
    ```
  
  - boot the kernel with its device tree
  
    ```sh
    bootz 0x61000000 - 0x62000000
    ```
  
    > Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
    > CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.19.6 #1
    > Hardware name: ARM-Versatile Express
    >  unwind_backtrace from show_stack+0x10/0x14
    >  show_stack from dump_stack_lvl+0x40/0x4c
    >  dump_stack_lvl from panic+0x100/0x318
    >  panic from mount_block_root+0x1a4/0x244
    >  mount_block_root from prepare_namespace+0x150/0x18c
    >  prepare_namespace from kernel_init+0x18/0x12c
    >  kernel_init from ret_from_fork+0x14/0x2c
    > Exception stack(0x88825fb0 to 0x88825ff8)
    > 5fa0:                                     00000000 00000000 00000000 00000000
    > 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
    > 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
    > ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0) ]---
    
    kernel crashed as it couldn't mount any root fs
    
    

you can do this automatically, so the bootloader will always load the kernel and dtb over tftp and boot using those two every time the board is booted or reset using bootcmd

```sh
setenv bootcmd 'tftp 0x61000000 zImage; tftp 0x62000000 vexpress-v2p-ca9.dtb; bootz 0x61000000 - 0x62000000'
saveenv
```





## Tiny Embedded system with BusyBox 

it's possible to link the rootfile system on target to root file system on the host (development workstation) through NFS(network file system), this ease your life as 

- you don't have to flash the file system every time a change is made  
- if you don't have support for external of internal storage yet, this can help you (HW development phase) 
- you can have a **huge** filesystem that include all the native toolchain tools

![Screenshot from 2022-09-05 04-52-32](Readme.assets/Screenshot from 2022-09-05 04-52-32.png)



### mounting rootfs over the network

On development workstation

```sh
# Install an NFS server
sudo apt install nfs-kernel-server
# add exported directory to `/etc/exports` file, with target ip as follows
/home/ahmed/Documents/linux_amit/Embedded_linux/Linux-yocto-Excersises/linux/4-linux_cross_compilation/rootfs 192.168.0.100(rw,no_root_squash,no_subtree_check)
# ask you NFS server to apply this new configuration (reload this file)
sudo exportfs -r
```

On target system

- Kernel must be **compiled** with (already exist)

  - `CONFIG_NFS_FS=y`, NFS client support

  - `CONFIG_IP_PNP=y`, configure IP at boot time

  - `CONFIG_ROOT_NFS=y`, support for NFS as rootfs

    

- Kernel must be **booted** with the following parameters:\

  - `root=/dev/nfs`,  we need rootfs over NFS
  - `ip=192.168.1.111`, target ip address
  - `nfsroot=192.168.1.110:/home/tux/rootfs`, NFS server details
  - `nfsvers=3,tcp` to `nfsroot` settings as the nfsroot setting may be rejected by NFS server on host machine

  this can be done by changing the `bootargs` as follows (note use **same qemu command as before**)

  ```sh 
  setenv bootargs ${bootargs} root=/dev/nfs ip=192.168.0.100:::::eth0 nfsroot=192.168.0.1:/home/ahmed/Documents/busybox/_install,nfsvers=3,tcp rw init=/sbin/init
  saveenv
  reset
  ```

  > IP-Config: Guessing netmask 255.255.255.0
  > IP-Config: Complete:
  >      device=eth0, hwaddr=52:54:00:12:34:56, ipaddr=192.168.0.100, mask=255.255.255.0, gw=255.255.255.255
  >      host=192.168.0.100, domain=, nis-domain=(none)
  >      bootserver=255.255.255.255, rootserver=192.168.0.1, rootpath=
  > ALSA device list:
  >   #0: ARM AC'97 Interface PL041 rev0 at 0x10004000, irq 32
  > VFS: Mounted root (nfs filesystem) on device 0:13.
  > devtmpfs: error mounting -2
  > Freeing unused kernel image (initmem) memory: 1024K
  > Run /sbin/init as init process
  > Run /etc/init as init process
  > Run /bin/init as init process
  > Run /bin/sh as init process
  > Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
  > CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.19.6 #1
  > Hardware name: ARM-Versatile Express
  >  unwind_backtrace from show_stack+0x10/0x14
  >  show_stack from dump_stack_lvl+0x40/0x4c
  >  dump_stack_lvl from panic+0x100/0x318
  >  panic from kernel_init+0x128/0x12c
  >  kernel_init from ret_from_fork+0x14/0x2c
  > Exception stack(0x88825fb0 to 0x88825ff8)
  > 5fa0:                                     00000000 00000000 00000000 00000000
  > 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
  > 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
  > ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---

`devtmpfs: error mounting -2` is happening because the kernel is tring to mount the *devmpfs* file system in the */dev/* in the root filesystem --> to solve this issue create a /dev/ directory under `nfsroot` and `reboot`

> IP-Config: Guessing netmask 255.255.255.0
> IP-Config: Complete:
>      device=eth0, hwaddr=52:54:00:12:34:56, ipaddr=192.168.0.100, mask=255.255.255.0, gw=255.255.255.255
>      host=192.168.0.100, domain=, nis-domain=(none)
>      bootserver=255.255.255.255, rootserver=192.168.0.1, rootpath=
> ALSA device list:
>   #0: ARM AC'97 Interface PL041 rev0 at 0x10004000, irq 32
> VFS: Mounted root (nfs filesystem) on device 0:13.
> devtmpfs: mounted
> Freeing unused kernel image (initmem) memory: 1024K
> Run /sbin/init as init process
> Run /etc/init as init process
> Run /bin/init as init process
> Run /bin/sh as init process
> Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
> CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.19.6 #1
> Hardware name: ARM-Versatile Express
>  unwind_backtrace from show_stack+0x10/0x14
>  show_stack from dump_stack_lvl+0x40/0x4c
>  dump_stack_lvl from panic+0x100/0x318
>  panic from kernel_init+0x128/0x12c
>  kernel_init from ret_from_fork+0x14/0x2c
> Exception stack(0x88825fb0 to 0x88825ff8)
> 5fa0:                                     00000000 00000000 00000000 00000000
> 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
> ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---

Note: Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]

our system is mostly empty there isn't such an application yet.

### root filesystem with busybox

**busybox**: light weight basic set of programs to

- init linux system (init program)
- shell
- utilities for file manipulation and system configuration  

 

we need to download, configure and cross compile then install **busybox** in the **nfsroot** directory.

```sh
git clone git://git.busybox.net/busybox
cd busybox/
make menuconfig # build statically
export PATH=$HOME/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/bin/:$PATH
export CROSS_COMPILE=arm-cortexa9_neon-linux-uclibcgnueabihf-
export ARCH=arm
make 
make install # output is by default placed in _install/
cp -r  _install/* ../rootfs/
```



Notice: `rootfs/sbin/init` is not here, let's start kernel again

> IP-Config: Guessing netmask 255.255.255.0
> IP-Config: Complete:
>      device=eth0, hwaddr=52:54:00:12:34:56, ipaddr=192.168.0.100, mask=255.255.255.0, gw=255.255.255.255
>      host=192.168.0.100, domain=, nis-domain=(none)
>      bootserver=255.255.255.255, rootserver=192.168.0.1, rootpath=
> ALSA device list:
>   #0: ARM AC'97 Interface PL041 rev0 at 0x10004000, irq 32
> VFS: Mounted root (nfs filesystem) on device 0:13.
> devtmpfs: mounted
> Freeing unused kernel image (initmem) memory: 1024K
> Run /sbin/init as init process
> random: init: uninitialized urandom read (4 bytes read)
> can't run '/etc/init.d/rcS': No such file or directory

init process started but **can't run '/etc/init.d/rcS': No such file or directory**, to access to sh is there press enter

Please press Enter to activate this console. 
random: sh: uninitialized urandom read (4 bytes read)
~ # 
~ # 

the folder that carry the configurations is `etc` folder, didnot exist also the `/proc` `/sys`

### virtual file systems

try `ps`  command on host

>    PID TTY          TIME CMD
>   86648 pts/2    00:00:00 bash
>  175312 pts/2    00:00:00 ps

`ps`  on target

> random: ps: uninitialized urandom read (4 bytes read)
> PID   USER     TIME  COMMAND
> ps: can't open '/proc': No such file or directory

virtual file systems don't exist on target create under `rootfs` folder thse folders`proc`,`sys` and `etc`  

`ps` again on target

>  PID   USER     TIME  COMMAND

### System configuration and startup 

The first user space program that gets executed by the kernel is `/sbin/init` and its configuration
file is `/etc/inittab`.

see `examples/inittab` file in `busybox` sources, copy `examples/inittab` to `/etc/`

> Freeing unused kernel image (initmem) memory: 1024K
> Run /sbin/init as init process
> random: init: uninitialized urandom read (4 bytes read)
> can't run '/etc/init.d/rcS': No such file or directory
>
> Please press Enter to activate this console. random: getty: uninitialized urandom read (4 bytes read)
> random: getty: uninitialized urandom read (4 bytes read)
>
> random: sh: uninitialized urandom read (4 bytes read)

create `/etc/init.d/rcS` startup script and in this script mount `/proc` `/sys` filesystems:

```sh 
#!/bin/sh
# mount a filesystem of type `proc` to /proc
mount -t proc nodev /proc
# mount a filesystem of type `sysfs` to /sys
mount -t sysfs nodev /sys
```

> Freeing unused kernel image (initmem) memory: 1024K
> Run /sbin/init as init process
> random: init: uninitialized urandom read (4 bytes read)
> can't run '/etc/init.d/rcS': Permission denied
>
> Please press Enter to activate this console. random: getty: uninitialized urandom read (4 bytes read)
> random: getty: uninitialized urandom read (4 bytes read)


try `ps` now and see `/proc`, note the the nfs update take up to 60 seconds

try compiling busybox again dynamically and add dynamic libraries to the system `lib` folder from crosstool-chain  (`ld-uClibc.so.0` is missing) and try to run the www server on linux operating system 
