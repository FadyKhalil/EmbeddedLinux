# Init Process

The **init process** is the first process that is started by the kernel during the boot process. The init process has a process ID (PID) of 1 and is responsible for starting and managing all other processes on the system.

In the following execices we will boot every time from NFS server, make sure to put all the folders for the root file system in

`/etc/exports`

then run `sudo exportfs -r` to update the nfs protocol with new folder added.

## BusyBox Init

The **busybox init** process then reads the system configuration files and starts various system services, such as network interfaces, device drivers, and daemons, to bring the system to a functional state.

### Create Rootfs

Using buildroot we set the configuration in filesystem to be **busybox init**

then we edit the **bootargs** in uboot to boot on the busybox init filesystem

```bash
setenv bootargs_busybox "setenv bootargs console=ttyS0,115200 root=/dev/nfs ip=192.168.7.100:::::eth0 nfsroot=192.168.7.1:/home/fady/rfs_bb,nfsvers=3,tcp rw init=/sbin/init"
```

then define bootcmd variable for busybox init

```bash
setenv bootcmd_busybox 'run bootargs_busybox; tftp 0x80200000 zImage; tftp 0x82000000 am335x-boneblack.dtb; bootz 0x80200000 - 0x82000000'
```

