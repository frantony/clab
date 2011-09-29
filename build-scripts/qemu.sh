#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for qemu.
# see http://www.qemu.org/
#

QEMU_BUILD_CFG=$1
if [ ! -f "$QEMU_BUILD_CFG" ]; then
	echo "no file $QEMU_BUILD_CFG"
	exit 1
fi

QEMU_BUILD_CFG=$(cd $(dirname $QEMU_BUILD_CFG); pwd)/$(basename $QEMU_BUILD_CFG)

. $DIST_DIR/functions

. $QEMU_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-qemu

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

run_with_check pushd $BUILD_DIR

run_with_check tar vfx $QEMU_SRC
run_with_check pushd $QEMU

for i in $PATCHES; do
	run_with_check patch -p0 < $i
done

if [ "$QEMU_STATIC" = "yes" ]; then
	QEMU_CONFIGURE_OPTS="$QEMU_CONFIGURE_OPTS --static"
fi

run_with_check ./configure $QEMU_CONFIGURE_OPTS
if [ "$MAKE_J" != "" ]; then
	QEMU_MAKE_J="-j $MAKE_J"
else
	QEMU_MAKE_J=""
fi

run_with_check make $QEMU_MAKE_J install
run_with_check popd

run_with_check popd
