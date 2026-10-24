# 8.4 - Layers

> Create your own layer, add it to the build, and understand layer priority.

| | |
|---|---|
| **Previous** | [8.3 - Build folder & configuration files](../2-FolderDescription/README.md) |
| **Next** | [8.5 - Basic variables](../4-Variables/Basic_Variables.md) |

## Background

A **layer** organises the configuration, recipes and other files needed to build a distribution. Layers make
the Yocto Project modular: you extend or customise a build by **adding** layers instead of editing others.

### Layer priority

When two layers provide the same recipe, or both append to it, **layer priority** decides which one wins.
Each layer sets its priority in `conf/layer.conf`:

```bash
# higher number = higher priority
BBFILE_PRIORITY_meta-mylayer = "6"
```

`bitbake-layers show-layers` prints the priority of every layer in the build.

## Steps

### 1. Create a layer

Run from your build directory (after `source poky/oe-init-build-env build`):

```bash
bitbake-layers create-layer ../meta-mylayer
```

This generates:

```text
meta-mylayer/
├── conf/
│   └── layer.conf              # layer name, priority, compatible releases
├── COPYING.MIT
├── README
└── recipes-example/
    └── example/
        └── example_0.1.bb      # a sample recipe
```

Open `conf/layer.conf` and look at `BBFILE_PRIORITY_...` and `LAYERSERIES_COMPAT_...` (the releases this layer works with, e.g. `scarthgap`).

### 2. Add the layer to the build

```bash
bitbake-layers add-layer ../meta-mylayer
bitbake-layers show-layers
```

### 3. Build the example recipe

```bash
bitbake example
```

## Checkpoint

`bitbake example` prints the recipe's message among the build log lines and ends with
`... all succeeded.`

## Exercises

1. Change `BBFILE_PRIORITY_meta-mylayer` and check the result with `bitbake-layers show-layers`.
2. Move on to [your first recipe](../5-BuildRecipe/README.md) and put it in this layer.
