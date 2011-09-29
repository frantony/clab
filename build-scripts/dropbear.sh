#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for dropbear -- lightweight SSH2 server and client.
# see http://matt.ucc.asn.au/dropbear/dropbear.html
#

DROPBEAR_BUILD_CFG=$1
if [ ! -f "$DROPBEAR_BUILD_CFG" ]; then
	echo "no file $DROPBEAR_BUILD_CFG"
	exit 1
fi

DROPBEAR_BUILD_CFG=$(cd $(dirname $DROPBEAR_BUILD_CFG); pwd)/$(basename $DROPBEAR_BUILD_CFG)

. $DIST_DIR/functions

. $DROPBEAR_BUILD_CFG

BUILD_DIR=$TMP_DIR/$VENDOR-build-dropbear

if [ "$MAKE_J" != "" ]; then
	DROPBEAR_MAKE_J="-j $MAKE_J"
else
	DROPBEAR_MAKE_J=""
fi

run_with_check rm -rf $BUILD_DIR
run_with_check mkdir -p $BUILD_DIR

run_with_check pushd $BUILD_DIR
run_with_check tar vfx $DROPBEAR_SRC
run_with_check pushd $DROPBEAR
run_with_check ./configure --disable-zlib --prefix=/usr $DROPBEAR_CONFIGURE_OPTS CC=${CROSS_COMPILE}gcc
#run_with_check make PROGRAMS="dropbearkey dropbear dbclient scp" MULTI=1 STATIC=0 SCPPROGRESS=1
#run_with_check make PROGRAMS="dropbearkey dropbear dbclient scp" MULTI=1 STATIC=0 SCPPROGRESS=0
make PROGRAMS="dropbearkey dropbear dbclient scp" MULTI=1 STATIC=0 SCPPROGRESS=0
#run_with_check make $DROPBEAR_MAKE_J install DESTDIR=_install PROGRAMS="dropbearkey dropbear dbclient scp"
make $DROPBEAR_MAKE_J install DESTDIR=_install PROGRAMS="dropbearkey dropbear dbclient scp"
run_with_check popd

run_with_check mkdir -p $OUT_DIR
run_with_check mv $DROPBEAR/_install $DROPBEAR/$DROPBEAR.$TC_CFG._install
run_with_check tar czf $OUT_DIR/$DROPBEAR.$TC_CFG._install.tar.gz -C $DROPBEAR $DROPBEAR.$TC_CFG._install
chmod -x $OUT_DIR/$DROPBEAR.$TC_CFG.*
run_with_check popd
