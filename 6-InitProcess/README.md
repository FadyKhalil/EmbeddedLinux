# Init Process

The **init process** is the first process that is started by the kernel during the boot process. The init process has a process ID (PID) of 1 and is responsible for starting and managing all other processes on the system.

```bash
# To show the process tree
pstree -gn 
```

In the following execices we will boot every time from NFS server, make sure to put all the folders for the root file system in

`/etc/exports`

then run `sudo exportfs -r` to update the nfs protocol with new folder added.

## Create the APP

1. Create a **simple application** just to see it running in initialization.

2. Compile the App with **specific compiler for the board**

   You can see the Folder **InitApp** in the Repo.

## BusyBox Init

The **busybox init** process then reads the system configuration files and starts various system services, such as network interfaces, device drivers, and daemons, to bring the system to a functional state.

### Create Rootfs

Using buildroot Or Busybox we set the configuration in filesystem to be **busybox init**

then we edit the **bootargs** in uboot to boot on the busybox init filesystem

```bash
setenv bootargs_busybox "setenv bootargs console=ttyS0,115200 root=/dev/nfs ip=192.168.7.100:::::eth0 nfsroot=192.168.7.1:/home/fady/rfs_bb,nfsvers=3,tcp rw init=/sbin/init"
```

then define bootcmd variable for busybox init

```bash
setenv bootcmd_busybox 'run bootargs_busybox; tftp 0x80200000 zImage; tftp 0x82000000 am335x-boneblack.dtb; bootz 0x80200000 - 0x82000000'
```

### Add the application

We need to add the application into the init script so it run at startup.

We need to modify two script:

- `/etc/init.d/rcS1`

  ```bash
  echo "rsc1 is on"
  deamonapp &
  ```

- `/etc/init.d/rcK1`

  ```bash
  echo "shutdown deamon app"
  pkill -e deamonapp
  sleep 3
  ```

- Adding the script in inittab

  ```bash
  # mount proc and sys file system
  null::sysinit:/bin/mount -t proc proc /proc
  null::sysinit:/bin/mount -t sysfs sysfs /sys
  
  # Excute when the system start
  ::sysinit:/etc/init.d/rcS1
  
  # ask to enter to the shell
  console::adkfirst:-/bin/sh
  
  # Excute when the system will go down
  ::shutdown:/etc/init.d/rcK1
  ```


## SystemV init

The **BusyBox init** daemon just described is just a trimmed down version of System V init. Compared to the BusyBox init, System V init has two advantages:

- The boot scripts are written in a well-known formal make it easier to add more packages or bin to run at boot time. 
- It has the concept of runlevels.

### Setup

`/etc/init.d/deamonapp`

take in count that **deamonapp** is a script inside the init.d

```sh
#! /bin/sh
case "$1" in
      start)
           echo "Starting deamonapp........."
           start-stop-daemon -S -n deamonapp -a /bin/deamonapp &
           ;;
     stop)
           echo "Stopping deamonapp........."
           start-stop-daemon -K -n deamonapp
           ;;
     *)
           echo "Usage: $0 {start|stop}"
           exit 1
esac
exit 0
```

**start-stop-daemon** is a helper function that makes it easier to manipulate background processes such as this. It originally came from the Debian installer package, dpkg, but most embedded systems use the one from BusyBox. It starts the daemon with the -S parameter, making sure that there is never more than one instance running at any one time. To stop a daemon, you use the -K parameter, which causes it to send a signal, SIGTERM by default, to indicate to the daemon that it is time to terminate.

### Usage of the app

- Ask for Help

```sh
/etc/init.d/deamonapp --help
```

- stop service

```sh
/etc/init.d/deamonapp stop
```

- start service

```sh
/etc/init.d/deamonapp start
```

- Then add this script to one of the `/etc/rc<x>.d/` folders to specify on what run level we will start the application

  ```sh
  # from file system root we create a symbolic link to our application and place it in one of the rc<runlevel> folders(runlevel)
  ln -s ../init.d/deamonapp ./etc/rc5.d/S40deamonapp.sh
  # this simplic link file is named `S40`, S -> will call our script with `start` as argument, `40` order of execution
  ```

- To kill the application at when getting in specific runlevel we create similar symbolic link

  ```sh
  # Kill the process in runlevel 5
  ln -s ../init.d/deamonapp ./etc/rc5.d/K40deamonapp.sh
  # Kill the process in runlevel 4
  ln -s ../init.d/deamonapp ./etc/rc4.d/K40deamonapp.sh
  ```

  to kill the application we execute
  
  ```sh
  telinit 4 # switching to runlevel 4 will kill the application
  ```



## System D

- we need to create in systemd filesystem `./etc/systemd/system/deamonapp.service`

```bash
[Unit]
Description=app server
[Service]
Type=simple
ExecStart=/bin/deamonapp

[Install]
WantedBy=multi-user.target
```



then you can start and stop it using

```bash
# start readapp program
systemctl start deamonapp
```

but if you execute `ps ` command on terminal it will show that the application is running

```bash
# stop readapp program
systemctl stop deamonapp
```

but if you execute `ps ` command on terminal it will show that the application is **not** there

using

```bash
systemctl status deamonapp
```

to see the full log of our application we

```bash
journalctl -u deamonapp.service
#or for current boot only
journalctl -u deamonapp.service -b 
```



To make it **persistent**, **permanent** (application will boot for multiuser.target by default) we execute -------> **[Install]** section purpose

```bash
systemctl enable deamonapp
```



```bash
reboot
ps # not application is there Executing 
```

**Note:**

Now, you can see how services add dependencies without having to keep on editing target unit files. A target can have a directory named **<target_name>.target.wants**, which can contain links to services.

This is exactly the same as adding the dependent unit to the **[Wants]** list in the target.
