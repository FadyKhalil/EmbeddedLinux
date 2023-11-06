# Build Recipe

First, we need to create a layer like how we did in previous session, and create a recipe inside the layer.

folder structure

```sh
meta_mylayer --> recipes_example --> helloworld |--> files --> helloworld.c
						|--> helloworld.bb
```

## Source file (helloworld.c)

Implement a normal c code

```c
#include <stdio.h>

int main(void)
{
	printf("hello world!\n");
	return 0;
}
```



## Recipe file (helloworld.bb)

```bash
# A brief description of the Recipe
SUMMARY = "Hello World Program"

# Which Type of License are we going to use E.g MIT, GPL, BSD etc.
LICENSE = "MIT"

# License file location and its md5 checksum.
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# Source Files
SRC_URI = "file://helloworld.c"

# directory of output build
S = "${WORKDIR}/build"

# the compilation takes place.
do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} ${WORKDIR}/helloworld.c -o ${S}/helloworld
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/helloworld ${D}${bindir}/
}
```



### How to Generate md5 Checksum

```bash
# go to poky/meta
md5sum COPYING.MIT
```

