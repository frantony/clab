#!/bin/sh

SRC_DIR=src

mkdir -p $SRC_DIR
( cd $SRC_DIR; wget -c http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.13.0.tar.bz2 )
( cd $SRC_DIR; wget -c http://wiki.qemu.org/download/qemu-0.15.1.tar.gz )
( cd $SRC_DIR; wget -c http://busybox.net/downloads/busybox-1.19.3.tar.bz2 )
( cd $SRC_DIR; wget -c http://matt.ucc.asn.au/dropbear/releases/dropbear-2011.54.tar.bz2 )
( cd $SRC_DIR; wget -c http://horms.net/projects/kexec/kexec-tools/kexec-tools-2.0.2.tar.gz )
( cd $SRC_DIR; wget -c http://barebox.org/download/barebox-2011.11.0.tar.bz2 )
( cd $SRC_DIR; wget -c http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.1.tar.xz )

# pc bios
( cd $SRC_DIR; wget -c http://prizma.bmstu.ru/~antony/barebox/seabios+git20111001.tar.gz )
# sparc firmware
( cd $SRC_DIR; wget -c http://prizma.bmstu.ru/~antony/barebox/openbios+svn1047.tar.gz )
