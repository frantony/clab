#!/bin/sh

CONFIGS=""
#CONFIGS="$CONFIGS i686-pc"
#CONFIGS="$CONFIGS sparc-ss20"
#CONFIGS="$CONFIGS arm-versatile"
CONFIGS="$CONFIGS mips-malta"

for i in $CONFIGS;
do
	./build.sh --config build-configs/$i \
		--build-toolchain \
		--build-qemu \
		--clean-out-dir \
		--build-firmware \
		--build-linux \
		--build-rootfs \

	if [ "$?" != "0" ]; then
		exit 1
	fi
done
