#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for barebox.
# barebox is flexible ARM/MIPS/... firmware.
# see http://www.barebox.org
#

BAREBOX_BUILD_CFG=$1
if [ ! -f "$BAREBOX_BUILD_CFG" ]; then
	echo "no file $BAREBOX_BUILD_CFG"
	exit 1
fi

BAREBOX_BUILD_CFG=$(cd $(dirname $BAREBOX_BUILD_CFG); pwd)/$(basename $BAREBOX_BUILD_CFG)

. $DIST_DIR/functions

. $BAREBOX_BUILD_CFG

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR
run_with_check pushd $BUILD_DIR
run_with_check tar vfx $BAREBOX_SRC
run_with_check pushd $BAREBOX

run_with_check cp $BAREBOX_CONFIG .config

for i in $BAREBOX_PATCHES; do
	echo "Patch ... $(basename $i)"
	run_with_check patch -p1 < "$i"
done

run_with_check make oldconfig ARCH=$BAREBOX_ARCH

if [ "$MAKE_J" != "" ]; then
	BAREBOX_MAKE_J="-j $MAKE_J"
else
	BAREBOX_MAKE_J=""
fi

run_with_check make $BAREBOX_MAKE_J ARCH=$BAREBOX_ARCH CROSS_COMPILE=$CROSS_COMPILE

if [ "$MAKE_J" != "" ]; then
	BAREBOX_MAKE_J="-j $MAKE_J"
else
	BAREBOX_MAKE_J=""
fi

run_with_check mkdir -p $OUT_DIR
run_with_check cp barebox $OUT_DIR/$BAREBOX.$TC_CFG
run_with_check cp barebox.bin $OUT_DIR/$BAREBOX.$TC_CFG.bin
run_with_check popd

run_with_check popd
