# LAYERS

In Yocto Project, a "layer" is a fundamental concept used to organize and manage the configuration, recipes, and other components needed to build an embedded Linux distribution. Layers provide a modular and flexible way to extend and customize the Yocto Project to meet the specific requirements of your embedded system.

## Layer priority

In the Yocto Project, "layer priority" refers to the order in which Yocto Project layers are evaluated and applied when building an image or recipe. Layer priority plays a crucial role in determining which recipes and configurations take precedence when there are overlapping or conflicting definitions in multiple layers. It ensures that the desired behavior and components are included in the final image or recipe.

## Build a layer

To create a layer we need to run the following command

```sh
# create a layer
bitbake-layers create-layer <path/to/meta-layername>
```

entering to the new layer added we will find conf file it has the configuration of the the layer

we also will see example recipe we can run it by the following command

```shell
# run the example recipe
bitbake example
```

To add the layer

```sh
# Add the layer
bitbake-layers add-layer <path/to/meta-layername>
```

