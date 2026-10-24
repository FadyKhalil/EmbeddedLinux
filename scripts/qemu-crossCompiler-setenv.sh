# Source this file in every new terminal:  source scripts/qemu-crossCompiler-setenv.sh
# It points the build at the toolchain built in lesson 2 (Crosstool-NG).
# If you built the musl variant, replace "gnueabihf" with "musleabihf" below.

TOOLCHAIN=arm-cortexa9_neon-linux-gnueabihf

export PATH=${HOME}/x-tools/${TOOLCHAIN}/bin:$PATH
export CROSS_COMPILE=${TOOLCHAIN}-
export ARCH=arm
