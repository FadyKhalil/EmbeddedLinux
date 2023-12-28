# Task Build

To build a recipe we need to run some tasks

To list task inside a recipe we need to run

```sh
bitbake -c listtasks <recipe-name>	
```

The output of the task is list in alphabetics order.

The most common tasks are:

| Tasks                        | Description                                                  |
| ---------------------------- | ------------------------------------------------------------ |
| Fetch **(do_fetch)**         | Fetches the source code                                      |
| Unpack **(do_unpack)**       | unpacks the source code into a working directory             |
| Patch **(do_patch)**         | Locates patch files and applies them to the source code      |
| configure **(do_configure)** | Configures the source by enabling and disabling any build-time and configuration options for the software being built |
| Compile **(do_compile)**     | Compiles the source in the compilation directory             |
| Install **(do_install)**     | Copies files from the compilation directory to a holding area |



## Fetch Task

Fetch task it fetches the package source from the local or remote repository.

To fetch a package source you need to add the source in **SRC_URI** variable in the recipe.

**SRCREV** describe if you want to fetch specific revision (Commit hash)

to excute only the fetch task

```bash
bitbake -c do_fetch <recipe_name>
```

the output will be shown in download folder which is described in local.conf file.



## Unpack Task

Unpack task unpacks the package that has been downloaded with Fetch task.

the unpacking is stored in Working directory of the recipe, to show it

```shell
bitbake -e <recipe_name> | grep ^WORKDIR
```

in order to see the unpack what is does, first we set the variable **S** to the work directory of the recipe then run the following bitbake command

```bash
bitbake -c do_unpack <recipe_name>
```

the output will be show in work directory folder.



## Patch Task

Patch task locates the patch files and applies the patches to the sources if any patch is available.

This is optional task, executes if patch is available.

A patch files provides some explicit changes for a specific file. That can be applied to that file.

It can be defined in **SRC_URI** variable after the fetch or we can use **SRC_URI:append = <patch_file>**

to run the patch task

```bash
bitbake -c do_patch <recipe_name>
```



