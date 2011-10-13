#!/bin/sh

SRC_DIR=src

mkdir -p $SRC_DIR
( cd $SRC_DIR; wget -c http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.12.4.tar.bz2 )
( cd $SRC_DIR; wget -c http://wiki.qemu.org/download/qemu-0.15.0.tar.gz )
( cd $SRC_DIR; wget -c http://busybox.net/downloads/busybox-1.19.2.tar.bz2 )
( cd $SRC_DIR; wget -c http://matt.ucc.asn.au/dropbear/releases/dropbear-0.53.1.tar.bz2 )
( cd $SRC_DIR; wget -c http://barebox.org/download/barebox-2011.09.0.tar.bz2 )

# mips barebox
( cd $SRC_DIR; wget -c http://prizma.bmstu.ru/~antony/barebox/barebox-2011.08.0-next.tar.bz2 )

# pc bios
( cd $SRC_DIR; wget -c http://prizma.bmstu.ru/~antony/barebox/seabios+git20110914.tar.gz )
# sparc firmware
( cd $SRC_DIR; wget -c http://prizma.bmstu.ru/~antony/barebox/openbios+svn1047.tar.gz )
