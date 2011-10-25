#!/bin/bash

BUILD_TOOLCHAIN_FLAG="no"
BUILD_QEMU_FLAG="no"

CLEAN_OUT_DIR="no"
BUILD_FIRMWARE_FLAG="no"
BUILD_LINUX_FLAG="no"
BUILD_ROOTFS_FLAG="no"


do_help() {
    cat <<__EOF__
\`build.sh'

USAGE: ./build.sh <OPTION>...

Configuration:
  -h, --help              display this help and exit
  --build-toolchain       build and install toolchain
  --build-qemu            build and install qemu
  --clean-out-dir         clean 'out' directory
                          remove compiled firmware, linux and rootfs
  --build-firmware        build firmware and install it to 'out'
  --build-linux           build linux kernel and install it to 'out'
  --build-rootfs          build linux rootfs and install it to 'out'
                          rootfs contain busybox and dropbear
  --config <file>         get options from <file>

__EOF__
}

if [ $# -eq 0 ]; then
        do_help
	exit 1
fi

while [ $# -ne 0 ]; do
    case "$1" in
        --build-toolchain) BUILD_TOOLCHAIN_FLAG="yes"; shift;;
        --build-qemu)      BUILD_QEMU_FLAG="yes"; shift;;
        --clean-out-dir)   CLEAN_OUT_DIR="yes"; shift;;
        --build-firmware)  BUILD_FIRMWARE_FLAG="yes"; shift;;
        --build-linux)     BUILD_LINUX_FLAG="yes"; shift;;
        --build-rootfs)    BUILD_ROOTFS_FLAG="yes"; shift;;
        --config)          shift; BUILD_CFG=$1; shift;;

        --help|-h|*)       printf "Unrecognised option: '${1}'\n"; do_help; exit 1;;
    esac
done

if [ ! -f "$BUILD_CFG" ]; then
	echo "no config file $BUILD_CFG"
	exit 1
fi

BUILD_CFG=$(cd $(dirname $BUILD_CFG); pwd)/$(basename $BUILD_CFG)

. $BUILD_CFG

. functions

# force -j make option
#export MAKE_J=8

export ARCH
export VENDOR
export PREFIX
export TC_CFG
export CROSS_COMPILE

# build and install toolchain and emulator.
# the programs will be installed to PREFIX.
if [ "$BUILD_TOOLCHAIN_FLAG" = "yes" ]; then
	# if PREFIX exists then clean it.
	if [ -e $PREFIX ]; then
		# if toolchain was build with option <<read-only toolchain>>
		# make it writable.
		run_with_check chmod -R +w $PREFIX
		run_with_check rm -rf $PREFIX
	fi

	run_with_check build-scripts/toolchain.sh $BUILD_TOOLCHAIN_CONFIG
fi

#
# Build qemu emulator
#
if [ "$BUILD_QEMU_FLAG" = "yes" ]; then
# FIXME
	if [ -e $PREFIX ]; then
		run_with_check chmod -R +w $PREFIX
	fi
	run_with_check build-scripts/qemu.sh $BUILD_QEMU_CONFIG
	run_with_check chmod -R -w $PREFIX
fi

# build and install software that will be runned under the emulator.
# this software will be installed to OUT_DIR.

if [ "$CLEAN_OUT_DIR" = "yes" ]; then
	# if OUT_DIR exists then clean it.
	if [ -e $OUT_DIR ]; then
		run_with_check chmod -R +w $OUT_DIR
		run_with_check rm -rf $OUT_DIR
	fi
fi

run_with_check mkdir -p $OUT_DIR

#
# Build firmware
#
if [ "$BUILD_FIRMWARE_FLAG" = "yes" ]; then
	if [ "$ARCH" = "i686" ]; then
		run_with_check build-scripts/qemu-seabios.sh $BUILD_SEABIOS_CONFIG
	fi

	if [ "$ARCH" = "sparc" ]; then
		run_with_check build-scripts/qemu-openbios.sh $BUILD_OPENBIOS_CONFIG
	fi

	if [ "$ARCH" = "arm" -o "$ARCH" = "mips" ]; then
		run_with_check build-scripts/barebox.sh $BUILD_BAREBOX_CONFIG
	fi
fi

if [ "$BUILD_LINUX_FLAG" = "yes" ]; then
	run_with_check build-scripts/linux.sh $BUILD_LINUX_CONFIG
fi

if [ "$BUILD_ROOTFS_FLAG" = "yes" ]; then
	run_with_check build-scripts/busybox.sh $BUILD_BUSYBOX_CONFIG
	run_with_check build-scripts/dropbear.sh $BUILD_DROPBEAR_CONFIG
	if [ "$BUILD_KEXEC_TOOLS_CONFIG" != "" ]; then
		run_with_check build-scripts/kexec-tools.sh $BUILD_KEXEC_TOOLS_CONFIG
	fi

	run_with_check build-scripts/rootfs.sh $BUILD_ROOTFS_CONFIG
fi
