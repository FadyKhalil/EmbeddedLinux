# Variable Assignment

## Types of Variable Assignments

| Assignment | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| ?=         | This is used to assign the default value to varibale. It can be overridden. |
| ??=        | This is used to assign the default value to varibale. But it is a weak assignment. It can be overridden. If multiple assignments are done with this type, the the last one will be considered. |
| =          | This is a simple variable assignment. It requires " " and spaces are significant. But variables are expanded at the end. |
| :=         | This is an immediate variable expansion. The value assigned is expanded immediately. |
| +=         | This appends a value to a variable. The operator inserts **a space** between the current value and appended value. It takes effect immediately. |
| =+         | This prepends a value to a variable, The operator inserts **a space** between the current value and prepended value. It takes effect immediately. |
| .=         | This appends a value to a variable. The operator inserts **no space** between the current value and appended value. It takes effect immediately. |
| =.         | This prepends a value to a variable. The operator inserts **no space** between the current value and prepended value. It takes effect immediately. |
| :append    | This appends a value to a variable. The operator inserts **no space** between the current value and appended value. The effects are applied at variable expansion time rather than being immediately applied. |
| :prepend   | This appends a value to a variable. The operator inserts **no space** between the current value and appended value. The effects are applied at variable expansion time rather than being immediately applied. |
| :remove    | This remove values from lists. Specifying a value for removal causes all occurrences of that value to be removed from the variable. |

### How to Read Variable Value

```sh
bitbake -e <RECIPE_NAME> | grep ^<VARIABLE_NAME>=
```



## Assignment Type ?=

```sh
TEST ?= "foo"
TEST ?= "bar"
TEST ?= "val"
TEST ?= "var"

# The final value is TEST="foo" 
```



## Assignment Type ??=

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



## Assignment Type =

```sh
# Override
A ?= "foo"
A = "bar"

# The final value is A="bar" 

# Variable Expansion
A = "foo"
B = "${A}"
A = "bar"

# The final value is B="bar" 
```



## Assignment Type :=

```shell
# Override
A ?= "foo"
A := "bar"

# The final value is A="bar" 

# Variable Expansion
A = "foo"
B := "${A}"
A = "bar"
# The final value is B="foo" 
```



## Assignment Type += and =+

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

# The final value is A="var"

# Prepend
B ??= "val"
B =+ "var"

# The final value is B="var"
```



## Assignment Type .= and =.

```shell
# No Spaces are added here
# Needs to add extra space

# Append
A = "foo"
A .= "bar"

# The final value is A="foobar" 

# Prepend
B = "foo"
B =. "bar"

# The final value is B="barfoo"
```



## Assignment Type :append, :prepend and :remove

```shell
# No Spaces are added here
# Needs to add extra space
# Parsed at the end

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

#remove

A = "foo bar"
A:remove = "foo"
# The final value is A=" bar" 

A = "foo bar"
A:remove = "var"
A += "var"
# The final value is A=" foo bar val" 
```



## Reference

https://docs.yoctoproject.org/bitbake/2.2/bitbake-user-manual/bitbake-user-manual-metadata.html