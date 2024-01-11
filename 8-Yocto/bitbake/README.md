# Bitbake Cheat-sheet

This all commands that you need to know in bitbake

## Basic Commands

| Commands                                      | Descriptions                                                 |
| --------------------------------------------- | ------------------------------------------------------------ |
| bitbake -vDDD   <your-recipe>                 | Verbose                                                      |
| bitbake -s                                    | List recipe add in the bblayer in conf file that will be executed |
| bitbake -c listtasks   <recipe>               | List task will be excuted by the recipe                      |
| bitbake -c   <your-task your-recipe>          | Run specific task of the recipe                              |
| bitbake  <recipe>                             | Run all task in the recipe                                   |
| bitbake -c cleanall  <recipe>                 | Delete the recipe from work directory                        |
| bitbake -c devshell   <recipe>                | To trigger a shell inside the work directory if you wan to configure something manually |
| bitbake -c cleansstate  <recipe>              | Clean the cashes of the recipe build                         |
| bitbake -e  <recipe> \| grep  <variable-name> | if you want to see a specific variable value in your recipe  |
| bitbake-getvar  <env-variable-bitbake>        | if you want to list an environment variable in bitbake such as `LDFLAGS` |



## Bitbake-layers command

| Commands                        | Description   |
| ------------------------------- | ------------- |
| bitbake-layers   <add-layer>    | Add new layer |
| bitbake-layers   <remove-layer> | Remove layer  |
| bitbake-layers   <show-layers>  | Show layers   |
| bitbake-layers   <show-recipes> | show recipes  |



## Adding file into rootfs

```bash
DESCRIPTION = "Install file into rootfs"

LICENSE = "MTI"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MTI-2.0;md5=0835ade698e0bcf8506ecda2f7b4f302"

#to add extra directory to look at
FILESEXTRAPATHS_prepend := "${THISDIR}/files:" 

#take file from files directory
SRC_URI += "git://github.com/ \
file://file1 \
file://file2 \
"

# Output of the fetch code
S = "${WORKDIR}/git"


do_install_append() {
    #create custom dir into rootfs
    install -d ${D}{bindir}
    #copy files inside
    install -m 0644 ${S}/file1 ${D}{bindir}
    install -m 0644 ${S}/file2 ${D}{bindir}
}
```



# Increase Filesystem size of a .wic/.sdcard

For example setting the RootFS to 2GB would require the following addition to the `local.conf` file:

```bash
IMAGE_ROOTFS_SIZE = “2097152”
IMAGE_OVERHEAD_FACTOR = “1.0”
```