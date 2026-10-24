# 8.6 - Variable Assignment

> Predict the final value of any BitBake variable: the operators, when they are applied, and where spaces come from.

| | |
|---|---|
| **Previous** | [8.5 - Basic variables](Basic_Variables.md) |
| **Next** | [8.7 - Your first recipe](../5-BuildRecipe/README.md) |

## Types of variable assignments

| Assignment | Description |
| ---------- | ----------- |
| `?=`       | Assigns a default value, only if the variable has no value yet. It can be overridden. |
| `??=`      | Assigns a **weak** default value. It is applied only at the end of parsing, if nothing else set the variable. If several `??=` are used, the last one wins. |
| `=`        | Simple assignment. Quotes are required and spaces are significant. Variables inside are expanded **when the variable is used**, not when it is assigned. |
| `:=`       | Immediate expansion: the value is expanded at assignment time. |
| `+=`       | Appends a value, inserting **a space**. Takes effect immediately. |
| `=+`       | Prepends a value, inserting **a space**. Takes effect immediately. |
| `.=`       | Appends a value with **no space**. Takes effect immediately. |
| `=.`       | Prepends a value with **no space**. Takes effect immediately. |
| `:append`  | Appends a value with **no space**. Applied at variable expansion time (after all `=`, `+=`...), not immediately. |
| `:prepend` | Prepends a value with **no space**. Applied at variable expansion time, not immediately. |
| `:remove`  | Removes every occurrence of a value from a space-separated list. Applied last, at expansion time. |

### How to read a variable's value

```sh
bitbake -e <RECIPE_NAME> | grep ^<VARIABLE_NAME>=
```

## Assignment type `?=`

```sh
TEST ?= "foo"
TEST ?= "bar"
TEST ?= "val"
TEST ?= "var"

# The final value is TEST="foo"
```

## Assignment type `??=`

```sh
TEST ??= "foo"
TEST ??= "bar"
TEST ??= "val"
TEST ??= "var"

# The final value is TEST="var"
```

```sh
TEST ??= "foo"
TEST ?= "bar"
TEST ?= "val"
TEST ??= "var"

# The final value is TEST="bar"
```

## Assignment type `=`

```sh
# Override
A ?= "foo"
A = "bar"

# The final value is A="bar"

# Variable expansion
A = "foo"
B = "${A}"
A = "bar"

# The final value is B="bar"
```

## Assignment type `:=`

```shell
# Override
A ?= "foo"
A := "bar"

# The final value is A="bar"

# Variable expansion
A = "foo"
B := "${A}"
A = "bar"

# The final value is B="foo"
```

## Assignment types `+=` and `=+`

```bash
# Spaces are added here

# Append
A = "foo"
A += "bar"

# The final value is A="foo bar"

# Prepend
B = "foo"
B =+ "bar"

# The final value is B="bar foo"

# Append
A ?= "val"
A += "var"

# The final value is A="val var"
# (?= sets A immediately because A was empty, then += appends)

# Prepend
B ??= "val"
B =+ "var"

# The final value is B="var"
# (??= is only applied at the end, and by then B already has a value)
```

## Assignment types `.=` and `=.`

```shell
# No spaces are added here: add one yourself if you need it

# Append
A = "foo"
A .= "bar"

# The final value is A="foobar"

# Prepend
B = "foo"
B =. "bar"

# The final value is B="barfoo"
```

## Assignment types `:append`, `:prepend` and `:remove`

```shell
# No spaces are added here: add one yourself if you need it
# Applied at the end, after all the other operators

# Append
A = "foo"
A:append = "bar"
# The final value is A="foobar"

# Append
A = "foo"
A:append = "bar"
A += "val"
# The final value is A="foo valbar"

# Append
A = "foo"
A:append = " bar"
# The final value is A="foo bar"

# Prepend
A = "foo"
A:prepend = "bar"
# The final value is A="barfoo"

# Prepend
A = "foo"
A:prepend = "bar"
A =+ "val"
# The final value is A="barval foo"

# Prepend
A = "foo"
A:prepend = "bar "
# The final value is A="bar foo"

# Remove
A = "foo bar"
A:remove = "foo"
# The final value is A=" bar"

A = "foo bar"
A:remove = "var"
A += "var"
# The final value is A="foo bar "
# (:remove is applied last, so the "var" added by += is removed too)
```

> **Most common mistake:** `IMAGE_INSTALL:append = "git"` glues `git` to the previous package name.
> Always write `IMAGE_INSTALL:append = " git"` (leading space).

## Exercises

1. Put `TEST ?= "a"` and `TEST ??= "b"` in `local.conf`, then check the result with `bitbake-getvar TEST`.
2. Predict, then check: `A = "x"`, `A:append = "y"`, `A += "z"`.

## Reference

[BitBake user manual - syntax and operators](https://docs.yoctoproject.org/bitbake/2.8/bitbake-user-manual/bitbake-user-manual-metadata.html)
