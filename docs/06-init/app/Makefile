# heartbeat - demo daemon of the Embedded Linux course
#
#   make CROSS_COMPILE=arm-cortexa9_neon-linux-gnueabihf-   # cross-compile for the board
#   make                                                    # native build, to try it on the PC
#   make install DESTDIR=$HOME/rootfs                       # install into a rootfs folder
#
# Buildroot and Yocto pass their own CC, CFLAGS and LDFLAGS; those win over the defaults here.

CROSS_COMPILE ?=
ifeq ($(origin CC),default)
CC := $(CROSS_COMPILE)gcc
endif

CFLAGS ?= -O2
CFLAGS += -Wall -Wextra
# static by default, so it runs on a rootfs without shared libraries (lessons 5 and 6)
LDFLAGS ?= -static

PREFIX ?= /usr
DESTDIR ?=

all: heartbeat

heartbeat: heartbeat.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

install: heartbeat
	install -D -m 0755 heartbeat $(DESTDIR)$(PREFIX)/bin/heartbeat

clean:
	rm -f heartbeat

.PHONY: all install clean
