# Basic Variables

## Popular Variables

- **PN** (Package Name)
- **PV** (Package Version)
- **PR** (Package Revision)
- **WORKDIR** (Working Directory)
- **S** (Source)
- **D** (Destination)
- **B** (Build Directory)



## How to Declare Recipe

myrecipe_**0.1_r0**.bb

The part of the name in bold, such as "0.1," indicates the specific version of the recipe, "r0" represent the package revision.



## How to Read Variable Value

```
bitbake -e <RECIPE_NAME> | grep ^<VARIABLE_NAME>=
```

## Package Name (PN)

**PN** refers to a recipe name used by the Yocto build system as input to create a package. The name is extracted from the recipe file name.

## Package Version (PV)

**PV** is the version of the recipe. The version is normally extracted from the recipe filename.

## Package Revision (PR)

The revision of the recipe. The default value for this variable is “r0”

## Working Directory (WORKDIR)

The **WORKDIR** is the pathname of the work directory in which the Yocto build system builds a recipe. This directory is located within the TMPDIR directory structure and is specific to the recipe being built and the system for which it is being built.

## Source (S)

S is the location in the Build Directory where unpacked recipe source code resides. By default, this directory is WORKDIR/BPN-PV, where BPN is the base recipe name and PV is the recipe version.

## Destination (D)

D is the destination directory. It is the location in the Build Directory where components are installed by the do_install task. This location defaults to WORKDIR/image.

## Build Directory (B)

It is same as S.