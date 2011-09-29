#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for openbios firmware.
#

OPENBIOS_BUILD_CFG=$1
if [ ! -f "$OPENBIOS_BUILD_CFG" ]; then
	echo "no file $OPENBIOS_BUILD_CFG"
	exit 1
fi

OPENBIOS_BUILD_CFG=$(cd $(dirname $OPENBIOS_BUILD_CFG); pwd)/$(basename $OPENBIOS_BUILD_CFG)

. $DIST_DIR/functions

. $OPENBIOS_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-openbios

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

run_with_check pushd $BUILD_DIR

run_with_check tar vfx $OPENBIOS_SRC

run_with_check pushd $OPENBIOS

for i in $OPENBIOS_PATCHES; do
	run_with_check patch -p0 < $i
done

CROSS_COMPILE=$CROSS_COMPILE ./config/scripts/switch-arch $OPENBIOS_ARCH
run_with_check make

run_with_check popd
run_with_check popd

run_with_check cp $BUILD_DIR/$OPENBIOS/obj-$OPENBIOS_ARCH/openbios-builtin.elf $OUT_DIR/openbios-$OPENBIOS_ARCH
