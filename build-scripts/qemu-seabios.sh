#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for pc bios firmware.
#

SEABIOS_BUILD_CFG=$1
if [ ! -f "$SEABIOS_BUILD_CFG" ]; then
	echo "no file $SEABIOS_BUILD_CFG"
	exit 1
fi

SEABIOS_BUILD_CFG=$(cd $(dirname $SEABIOS_BUILD_CFG); pwd)/$(basename $SEABIOS_BUILD_CFG)

. $DIST_DIR/functions

. $SEABIOS_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-seabios

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

pushd $BUILD_DIR

tar vfx $SEABIOS_SRC
pushd $SEABIOS
make CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld
popd
popd

run_with_check cp $BUILD_DIR/$SEABIOS/out/bios.bin $OUT_DIR/

run_with_check pushd $BUILD_DIR
run_with_check tar vfx $QEMU_SRC
run_with_check pushd $QEMU
run_with_check ./configure $QEMU_CONFIGURE_OPTS
run_with_check cd pc-bios/optionrom
run_with_check make linuxboot.bin multiboot.bin CC=${CROSS_COMPILE}gcc LD=${CROSS_COMPILE}ld
run_with_check popd
run_with_check popd

run_with_check cp $BUILD_DIR/$QEMU/pc-bios/optionrom/linuxboot.bin $OUT_DIR/
run_with_check cp $BUILD_DIR/$QEMU/pc-bios/optionrom/multiboot.bin $OUT_DIR/
