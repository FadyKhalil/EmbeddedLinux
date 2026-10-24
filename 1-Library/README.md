# 1 - Libraries

> Understand static and dynamic libraries, because every binary you put on the board depends on one or the other.

| | |
|---|---|
| **Boards** | Host PC only (the same ideas apply on the target) |
| **Time** | ~30 min |
| **Previous** | - |
| **Next** | [2 - Cross toolchain](../2-Crosstool_Ng/README.md) |

## What you will learn

- What a library is and how the linker uses it
- How to build and use a **static** library (`.a`)
- How to build and use a **dynamic** (shared) library (`.so`)
- Why shared libraries must also be copied to the target's root filesystem

## Prerequisites

- `gcc` and `make` on the host (`sudo apt install build-essential`)

## Background

A **library** is a package of pre-compiled functions you can reuse instead of rewriting them. A library is
not an executable: it has no `main()`, it is linked into a program that does.

| | Static library (`.a`) | Dynamic library (`.so`) |
|---|---|---|
| Linked | At build time, code is **copied into** the executable | At run time, by the dynamic loader |
| Executable size | Bigger | Smaller |
| Needed on target at run time | No | **Yes**, in `/lib` or `/usr/lib` |
| Update the library | Rebuild every program | Replace the `.so` once |

On an embedded board this matters: if you link dynamically, the `.so` files (including the C library
from your toolchain) must be present in the root filesystem you build in [lesson 5](../5-Busybox/README.md).

## Steps

Both parts use the same small library, `mylib`, with one function `add_numbers`.

```c
// mylib.h
#ifndef MYLIB_H
#define MYLIB_H

int add_numbers(int a, int b);

#endif
```

```c
// mylib.c
#include "mylib.h"

int add_numbers(int a, int b) {
    return a + b;
}
```

```c
// main.c
#include <stdio.h>
#include "mylib.h"

int main(void) {
    int result = add_numbers(5, 7);
    printf("Result: %d\n", result);
    return 0;
}
```

### Part A - Static library

#### 1. Compile the library source into an object file

```bash
gcc -c mylib.c -o mylib.o
```

#### 2. Archive the object file into a static library

```bash
# r = insert/replace, c = create, s = write an index
ar rcs libmylib.a mylib.o
```

#### 3. Link your program against it

```bash
gcc main.c -o my_program -L. -lmylib
# OR give the archive file directly
gcc main.c libmylib.a -o my_program
```

`-L.` tells the linker to also search the current directory, and `-lmylib` means "find `libmylib.a` or `libmylib.so`".

#### 4. Run it

```bash
./my_program
```

### Part B - Dynamic library

#### 1. Build the shared library

```bash
gcc -shared -fPIC -o libmylib.so mylib.c
```

`-shared` creates a shared object; `-fPIC` generates position-independent code, required because the
library can be loaded at any address.

#### 2. Link your program against it

```bash
# remove the static one first, otherwise the linker may pick it
rm -f libmylib.a
gcc main.c -o my_program -L. -lmylib
```

#### 3. Run it

The dynamic loader only searches the standard library folders, so tell it where `libmylib.so` is:

```bash
LD_LIBRARY_PATH=. ./my_program
```

## Checkpoint

```text
Result: 12
```

Check which kind of linking you got:

```bash
ldd ./my_program     # dynamic build lists libmylib.so; static build does not
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `error while loading shared libraries: libmylib.so: cannot open shared object file` | Loader can't find the `.so` | Run with `LD_LIBRARY_PATH=.` or copy it to `/usr/lib` |
| `undefined reference to 'add_numbers'` | Library not given to the linker, or given before `main.c` | Put `-lmylib` **after** the source files |
| `cannot find -lmylib` | Wrong `-L` path or wrong file name | The file must be named `lib<name>.a` / `lib<name>.so` |

## Exercises

1. Build both libraries, then compare `ls -l my_program` for the static and dynamic versions.
2. Change `add_numbers` to multiply, rebuild **only** `libmylib.so`, and run the dynamic program again without relinking.
3. After lesson 2: cross-compile the same program with `${CROSS_COMPILE}gcc` and check it with `file`.

## Recap

- Static libraries are copied into the program; dynamic ones must exist on the target at run time.
- Next you will build the cross compiler that produces ARM versions of all of this.
