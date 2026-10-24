# 1 · Libraries

> Understand static and shared libraries, because every binary you put on the board depends on one or the other.

| | |
|---|---|
| **Boards** | Host PC (the same ideas apply on the target) |
| **Time** | ~30 min |
| **Next** | [2 · Cross toolchain](../02-toolchain/README.md) |

## What you will learn

- What a library is and how the linker uses it
- How to build and use a **static** library (`.a`)
- How to build and use a **shared** library (`.so`)
- Why shared libraries must also be copied into the target's root filesystem

## Background

A **library** is a package of pre-compiled functions you can reuse instead of rewriting them. It has no
`main()`, so it can't run by itself: it is linked into a program that does.

<figure class="el-anim">
<img src="linking.svg" alt="Static linking copies library code into the program; dynamic linking leaves a reference that the loader resolves on the target">
<ol class="el-anim-steps">
<li><b>Static linking.</b> The linker receives your object file <code>main.o</code> and the archive <code>libmylib.a</code>.</li>
<li>The code of every library function you call (here <code>add_numbers()</code>) is <b>copied into</b> <code>my_program</code>.</li>
<li>The program is self-contained: it runs on the board without any library file next to it.</li>
<li><b>Dynamic linking.</b> With <code>libmylib.so</code> the linker copies nothing. It only records "this program <b>needs</b> libmylib.so".</li>
<li>At run time, the <b>dynamic loader</b> (<code>ld-linux.so</code>) finds <code>libmylib.so</code> in the board's <code>/lib</code> or <code>/usr/lib</code> and maps it in. If it's not in the root filesystem, the program won't start.</li>
</ol>
<figcaption>▶ This diagram is animated on the <a href="https://fadykhalil.github.io/EmbeddedLinux/01-libraries/index.html">course website</a>.</figcaption>
</figure>

| | Static library (`.a`) | Shared library (`.so`) |
|---|---|---|
| Linked | At build time: code is **copied into** the executable | At run time, by the dynamic loader |
| Executable size | Bigger | Smaller |
| Needed on the target at run time | No | **Yes**, in `/lib` or `/usr/lib` |
| Fix a bug in the library | Rebuild every program | Replace the one `.so` file |

> [!IMPORTANT]
> On an embedded board this decides what goes into the root filesystem. A dynamically linked program needs its
> `.so` files, including the C library from your toolchain, in the rootfs you build in [lesson 5](../05-rootfs/README.md).
> That's why the early lessons build **static** binaries.

## Steps

Both parts use the same small library, `mylib`, with a single function `add_numbers`.

```c title="mylib.h"
#ifndef MYLIB_H
#define MYLIB_H

int add_numbers(int a, int b);

#endif
```

```c title="mylib.c"
#include "mylib.h"

int add_numbers(int a, int b) {
    return a + b;
}
```

```c title="main.c"
#include <stdio.h>
#include "mylib.h"

int main(void) {
    int result = add_numbers(5, 7);
    printf("Result: %d\n", result);
    return 0;
}
```

### Part A · Static library

#### 1. Compile the library into an object file

```bash
gcc -c mylib.c -o mylib.o
```

#### 2. Archive it into a static library

```bash
# r = insert/replace, c = create, s = write an index
ar rcs libmylib.a mylib.o
```

#### 3. Link your program against it

```bash
gcc main.c -o my_program -L. -lmylib
# or give the archive file directly
gcc main.c libmylib.a -o my_program
```

`-L.` adds the current directory to the linker's search path, and `-lmylib` means "find `libmylib.a` or `libmylib.so`".

#### 4. Run it

```bash
./my_program
```

### Part B · Shared library

#### 1. Build the shared library

```bash
gcc -shared -fPIC -o libmylib.so mylib.c
```

`-shared` creates a shared object; `-fPIC` generates position-independent code, required because the library
can be loaded at any address.

#### 2. Link your program against it

```bash
# remove the static one first, otherwise the linker may pick it
rm -f libmylib.a
gcc main.c -o my_program -L. -lmylib
```

#### 3. Run it

The loader only searches the standard library folders, so tell it where `libmylib.so` is:

```bash
LD_LIBRARY_PATH=. ./my_program
```

## Checkpoint

```text
Result: 12
```

Check which kind of linking you got:

```bash
ldd ./my_program     # the shared build lists libmylib.so; the static build doesn't
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `error while loading shared libraries: libmylib.so: cannot open shared object file` | Loader can't find the `.so` | Run with `LD_LIBRARY_PATH=.` or copy it to `/usr/lib` |
| `undefined reference to 'add_numbers'` | Library not given to the linker, or given before `main.c` | Put `-lmylib` **after** the source files |
| `cannot find -lmylib` | Wrong `-L` path or file name | The file must be called `lib<name>.a` / `lib<name>.so` |

## Exercises

1. Build both versions and compare `ls -l my_program`.
2. Change `add_numbers` to multiply, rebuild **only** `libmylib.so`, and run the shared program again without relinking it.
3. After lesson 2: cross-compile the program with `${CROSS_COMPILE}gcc` and check it with `file`.

## Recap

- Static libraries are copied into the program; shared ones must exist on the target at run time.
- Next you'll build the cross compiler that produces ARM versions of all this.
