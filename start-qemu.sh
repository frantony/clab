#!/bin/bash
#
# clab MIPS framework
# (c) 2010, 2011 Antony Pavlov
#
# qemu start script
#

QEMU_BASE_DIR=$(pwd)
QEMU_AUX=$QEMU_BASE_DIR/qemu-configs

XTERM_FONT=""
XTERM_FONT="-fn -xos4-terminus-medium-r-normal-*-24-*-*-*-*-*-iso10646-1"
XTERM="xterm"

QEMU_GRAPHIC_CMD="-vga cirrus" # don't works with malta
QEMU_GRAPHIC_CMD=-nographic

QEMU_L_CMD="-L ."
QEMU_L_CMD=""

QEMU_CONFIG=$1

if [ ! -f "$QEMU_CONFIG" ]; then
	echo "Usage:"
	echo "$0 <config>"
	exit 1
fi

#
# GDB (by default turned off)
#
GDB_UI=""
GDB_QUIET=""
GDB=""
GDB_X_CMD=""
QEMU_GDB_CMD=""

QEMU_CONFIG=$(cd $(dirname $QEMU_CONFIG); pwd)/$(basename $QEMU_CONFIG)
. $QEMU_CONFIG

QEMU_LOG_PREFIX=$QEMU_BASE_DIR/log
QEMU_LOG=$QEMU_LOG_PREFIX/qemu$QEMU_LOG_SUFFIX.log
QEMU_DEBUG_LOG=$QEMU_LOG_PREFIX/qemu$QEMU_LOG_SUFFIX.debug.log
XTERM_LOGGING="-l -lf $QEMU_LOG"
XTERM_CMD="$XTERM $XTERM_LOGGING $XTERM_FONT"

if [ "$QEMU_CPU" != "" ]; then
	QEMU_CPU_CMD="-c $QEMU_CPU"
fi

if [ "$QEMU_MEMSIZE" != "" ]; then
	QEMU_MEMSIZE_CMD="-m $QEMU_MEMSIZE"
fi

if [ "$QEMU_MACH" != "" ]; then
	QEMU_MACH_CMD="-M $QEMU_MACH"
fi

QEMU_BIOS_CMD=""
if [ "$QEMU_BIOS" != "" ]; then
	QEMU_BIOS_CMD="-bios $QEMU_BIOS"
fi
if [ "$QEMU_BIOS_PATH" != "" ]; then
	QEMU_BIOS_CMD="$QEMU_BIOS_CMD -L $QEMU_BIOS_PATH"
fi

if [ "$QEMU_SYSTEM_ARCH" = "mips" -o "$QEMU_SYSTEM_ARCH" = "mipsel" ]; then
	if [ "$QEMU" = "" ]; then
		QEMU=qemu-system-mips
	fi

	if [ "$GDB_X_CMD" = "" ]; then
		GDB_X_CMD="-x $QEMU_AUX/mips32r2.gdb.cmd"
	fi
fi

if [ "$QEMU_SYSTEM_ARCH" = "mips64" ]; then
	if [ "$QEMU" = "" ]; then
		QEMU=qemu-system-mips64
	fi

	if [ "$GDB_X_CMD" = "" ]; then
		GDB_X_CMD="-x $QEMU_AUX/mips64r2.gdb.cmd"
	fi
fi

if [ "$QEMU_SYSTEM_ARCH" = "arm" ]; then
	if [ "$QEMU" = "" ]; then
		QEMU=qemu-system-arm
	fi

	if [ "$GDB_X_CMD" = "" ]; then
		GDB_X_CMD="-x $QEMU_AUX/armv5.gdb.cmd"
	fi
fi

if [ -f "$GDB_SYM_FILE" ]; then
	GDB_SYM_CMD="-s $GDB_SYM_FILE"
else
	GDB_SYM_CMD=""
fi

# avoid default surprises
QEMU="$QEMU -nodefaults"

case "$QEMU_START_MODE" in
	"x-terminal" | "stdio")
	QEMU_SERIAL="-serial stdio"
	QEMU_MONITOR="-monitor null"
	;;

	"monitor-only")
	QEMU_SERIAL="-serial null"
	QEMU_MONITOR="-monitor stdio"
	;;

	"quiet")
	QEMU_SERIAL="-serial null"
	QEMU_MONITOR="-monitor null"
	;;

	"custom")
	;;

	*)
	echo "Unknown QEMU_START_MODE!!!"
	exit 1
	;;
esac

if [ ! -d "$QEMU_LOG_PREFIX" ]; then
	mkdir -p "$QEMU_LOG_PREFIX"
fi

echo -n > $QEMU_LOG
echo -n > $QEMU_DEBUG_LOG

QEMU_CMD="$QEMU $QEMU_BIOS_CMD $QEMU_SERIAL $QEMU_MONITOR $QEMU_MACH_CMD $QEMU_CPU_CMD $QEMU_MEMSIZE_CMD $QEMU_GRAPHIC_CMD $QEMU_NET0_CMD $QEMU_NET1_CMD $QEMU_NET2_CMD $QEMU_L_CMD $QEMU_GDB_CMD $KERNEL_CMD $INITRD_CMD $APPEND_CMD $DISK_IMAGE 2>>$QEMU_DEBUG_LOG"

echo $QEMU_CMD
echo "$GDB $GDB_SYM_CMD $GDB_X_CMD"

case "$QEMU_START_MODE" in
	"x-terminal")

	if [ "$QEMU_GDB_CMD" != "" ]; then
		$XTERM -title "start-qemu.sh: gdb" -e "$GDB $GDB_SYM_CMD $GDB_X_CMD" &
	fi

	$XTERM -title "start-qemu.sh: serial0" -e "$QEMU_CMD" &
	tail -n 100 -f $QEMU_DEBUG_LOG
	wait
	;;

	"stdio" | "monitor-only" | "quiet")
	sh -c "$QEMU_CMD"
	;;
esac
