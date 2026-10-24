# 8.5 · Basic Variables

> Learn the variables every recipe uses, and how to read their values.

| | |
|---|---|
| **Previous** | [8.4 · Layers](04-layers.md) |
| **Next** | [8.6 · Variable assignment](06-variable-assignment.md) |

## Popular variables

| Variable | Meaning | Default |
|---|---|---|
| `PN` | Package (recipe) name | From the file name |
| `PV` | Package version | From the file name, else `1.0` |
| `PR` | Package revision | `r0` |
| `WORKDIR` | The recipe's work directory | A folder under `${TMPDIR}/work/` |
| `S` | Unpacked source code | `${WORKDIR}/${BPN}-${PV}` |
| `B` | Build directory | `${S}` |
| `D` | Install destination used by `do_install` | `${WORKDIR}/image` |

## How the recipe file name sets PN and PV

```text
myrecipe_0.1.bb
   |      |
   PN     PV
```

The part before the underscore is the recipe name (`PN`), the part after is the version (`PV`).
`PR` is **not** part of the file name; set it inside the recipe if you need it (`PR = "r1"`).

## How to read a variable's value

```bash
bitbake -e <recipe_name> | grep ^<VARIABLE_NAME>=

# newer and shorter
bitbake-getvar -r <recipe_name> <VARIABLE_NAME>
```

## Details

### Package name (`PN`)

The name of the recipe, used by the build system as input to create packages. Extracted from the recipe file name.

### Package version (`PV`)

The version of the recipe, normally extracted from the recipe file name.

### Package revision (`PR`)

The revision of the recipe. Default `r0`.

### Working directory (`WORKDIR`)

The path where the build system builds the recipe. It's inside `TMPDIR` and is specific to the recipe and the
target it's built for.

### Source (`S`)

Where the unpacked source code is. Default `${WORKDIR}/${BPN}-${PV}`, where `BPN` is the base recipe name.
Recipes that fetch from git usually set `S = "${WORKDIR}/git"`.

### Destination (`D`)

Where `do_install` puts the files. Default `${WORKDIR}/image`; everything here ends up in the packages.

### Build directory (`B`)

Where compilation happens. Same as `S` by default; some classes (e.g. `cmake`) use a separate folder.

## Exercises

1. Print `PN`, `PV`, `S` and `D` for the `busybox` recipe.
2. Rename your recipe from `example_0.1.bb` to `example_0.2.bb` and check `PV` again.
