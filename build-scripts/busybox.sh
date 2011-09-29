#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for busybox.
# see http://www.busybox.net
#

BUSYBOX_BUILD_CFG=$1
if [ ! -f "$BUSYBOX_BUILD_CFG" ]; then
	echo "no file $BUSYBOX_BUILD_CFG"
	exit 1
fi

BUSYBOX_BUILD_CFG=$(cd $(dirname $BUSYBOX_BUILD_CFG); pwd)/$(basename $BUSYBOX_BUILD_CFG)

. $DIST_DIR/functions

. $BUSYBOX_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-busybox

if [ "$MAKE_J" != "" ]; then
	BUSYBOX_MAKE_J="-j $MAKE_J"
else
	BUSYBOX_MAKE_J=""
fi

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

run_with_check pushd $BUILD_DIR
run_with_check tar vfx $BUSYBOX_SRC
run_with_check pushd $BUSYBOX
run_with_check cp $BUSYBOX_CONFIG .config
run_with_check make oldconfig
run_with_check make $BUSYBOX_MAKE_J install CROSS_COMPILE=$CROSS_COMPILE

run_with_check popd

run_with_check mv $BUSYBOX/.config $OUT_DIR/$BUSYBOX.$TC_CFG.config
run_with_check mv $BUSYBOX/_install $BUSYBOX/$BUSYBOX.$TC_CFG._install
run_with_check tar czf $OUT_DIR/$BUSYBOX.$TC_CFG._install.tar.gz -C $BUSYBOX $BUSYBOX.$TC_CFG._install
chmod -x $OUT_DIR/$BUSYBOX.$TC_CFG.*
run_with_check popd
