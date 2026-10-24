# Embedded Linux From Scratch

A hands-on course that builds a complete embedded Linux system **one piece at a time**: first by hand
(toolchain → bootloader → kernel → root filesystem → init), then with the build systems used in industry,
**Buildroot** and **Yocto**. Every lesson works on **QEMU** (no hardware needed), a **Raspberry Pi** or a
**BeagleBone Black**.

### 📖 [Read the course on the website](https://fadykhalil.github.io/EmbeddedLinux/)

The website has search, dark mode, copy buttons on every command, and **step-by-step animations** of how each
piece works. Everything also reads fine right here on GitHub.

![Boot chain: ROM code, SPL, U-Boot, kernel and device tree, root filesystem, init, your application](docs/boot-chain.svg)

## Lessons

| # | Lesson | You will build / learn |
|---|---|---|
| 1 | [Libraries](docs/01-libraries/README.md) | Static vs. shared libraries, what has to be on the target |
| 2 | [Cross toolchain](docs/02-toolchain/README.md) | Your own ARM cross compiler with Crosstool-NG |
| 3 | [U-Boot](docs/03-u-boot/README.md) | Bootloader, SD card layout, TFTP |
| 4 | [Linux kernel](docs/04-kernel/README.md) | Configure, build and boot a kernel + device tree |
| 5 | [Root filesystem](docs/05-rootfs/README.md) | A BusyBox rootfs over NFS, SD card and initramfs |
| 6 | [Init process](docs/06-init/README.md) | Start the `heartbeat` daemon with BusyBox init, System V and systemd |
| 7 | [Buildroot](docs/07-buildroot/README.md) | The whole system in one `make`, plus `heartbeat` as a package |
| 8 | [Yocto Project](docs/08-yocto/README.md) | Layers, recipes, variables, tasks, `heartbeat` as a recipe |

Extra: [Cross-compiling with CMake](docs/extras/cmake/06-cross-compiling.md).
Start with the [course home page](docs/index.md) for board choice, host setup and conventions.

## Repository layout

```text
docs/                  the course (Markdown + animated SVG diagrams)
├── 01-libraries/ … 08-yocto/
├── 06-init/app/       heartbeat: the demo daemon used in lessons 6-8
├── 07-buildroot/br2-external/   Buildroot package for heartbeat
├── scripts/           helper scripts (SD card, QEMU, toolchain environment)
├── extras/cmake/      CMake, including a cross-compilation toolchain file
└── contributing/      lesson template
mkdocs.yml             website configuration (MkDocs Material)
```

## Preview the website locally

```bash
pip install mkdocs-material==9.5.39 markdown-callouts==0.4.0
mkdocs serve       # then open http://127.0.0.1:8000
```

The site is published automatically to GitHub Pages on every push to `main`
(see [`.github/workflows/docs.yml`](.github/workflows/docs.yml)).

## Contributing

New lessons follow the [lesson template](docs/contributing/lesson-template.md): goal → prerequisites → background
(with an animation where it helps) → steps → checkpoint → troubleshooting → exercises. Found a broken command?
Please open an issue or a pull request.
