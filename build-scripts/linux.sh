#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for linux.
#
# see http://www.kernel.org
#     http://www.linux-mips.org

LINUX_BUILD_CFG=$1
if [ ! -f "$LINUX_BUILD_CFG" ]; then
	echo "no file $LINUX_BUILD_CFG"
	exit 1
fi

LINUX_BUILD_CFG=$(cd $(dirname $LINUX_BUILD_CFG); pwd)/$(basename $LINUX_BUILD_CFG)

. $DIST_DIR/functions

. $LINUX_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-linux

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

run_with_check pushd $BUILD_DIR

run_with_check tar vfx $LINUX_SRC

run_with_check pushd $LINUX
run_with_check cp $LINUX_CONFIG .config

for i in $LINUX_PATCHES; do
	run_with_check patch -p0 < $i
done

run_with_check make oldconfig ARCH=$LINUX_ARCH

if [ "$MAKE_J" != "" ]; then
	LINUX_MAKE_J="-j $MAKE_J"
else
	LINUX_MAKE_J=""
fi

if [ "$LINUX_ARCH" = "mips" ]; then
	run_with_check make $LINUX_MAKE_J vmlinux ARCH=mips CROSS_COMPILE=$CROSS_COMPILE
	run_with_check make $LINUX_MAKE_J vmlinuz ARCH=mips CROSS_COMPILE=$CROSS_COMPILE
fi

if [ "$LINUX_ARCH" = "x86" ]; then
	run_with_check make $LINUX_MAKE_J vmlinux ARCH=x86 CROSS_COMPILE=$CROSS_COMPILE
	run_with_check make $LINUX_MAKE_J bzImage ARCH=x86 CROSS_COMPILE=$CROSS_COMPILE
fi

if [ "$LINUX_ARCH" = "sparc" ]; then
	run_with_check make $LINUX_MAKE_J vmlinux ARCH=sparc CROSS_COMPILE=$CROSS_COMPILE
	run_with_check make $LINUX_MAKE_J zImage ARCH=sparc CROSS_COMPILE=$CROSS_COMPILE
fi

if [ "$LINUX_ARCH" = "arm" ]; then
	run_with_check make $LINUX_MAKE_J vmlinux ARCH=arm CROSS_COMPILE=$CROSS_COMPILE
	run_with_check make $LINUX_MAKE_J zImage ARCH=arm CROSS_COMPILE=$CROSS_COMPILE
fi

run_with_check popd

run_with_check mkdir -p $OUT_DIR

run_with_check cp $LINUX/vmlinux $OUT_DIR/vmlinux.$LINUX.$TC_CFG
run_with_check cp $LINUX/vmlinux.o $OUT_DIR/vmlinux.$LINUX.$TC_CFG.o

if [ "$LINUX_ARCH" = "mips" ]; then
	run_with_check cp $LINUX/vmlinuz $OUT_DIR/vmlinuz.$LINUX.$TC_CFG
fi

if [ "$LINUX_ARCH" = "x86" ]; then
	run_with_check cp $LINUX/arch/x86/boot/bzImage $OUT_DIR/bzImage.$LINUX.$TC_CFG
fi

if [ "$LINUX_ARCH" = "sparc" ]; then
	run_with_check cp $LINUX/arch/sparc/boot/zImage $OUT_DIR/zImage.$LINUX.$TC_CFG
fi

if [ "$LINUX_ARCH" = "arm" ]; then
	run_with_check cp $LINUX/arch/arm/boot/zImage $OUT_DIR/zImage.$LINUX.$TC_CFG
fi

run_with_check cp $LINUX/.config $OUT_DIR/vmlinux.$LINUX.$TC_CFG.config

run_with_check popd
