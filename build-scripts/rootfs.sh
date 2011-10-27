#!/bin/bash
#
# clab framework
# (c) 2011, Antony Pavlov
#
# build script for minimal rootfs image.
# need prebuilt busybox and dropbear ssh server.
#

PUBKEY=~/.ssh/id_rsa.pub

MKSQUASHFS=mksquashfs
# cramfsprogs
#MKCRAMFS=/usr/sbin/mkcramfs
# util-linux
MKCRAMFS=/sbin/mkfs.cramfs

ROOTFS_BUILD_CFG=$1
if [ ! -f "$ROOTFS_BUILD_CFG" ]; then
	echo "no file $ROOTFS_BUILD_CFG"
	exit 1
fi

ROOTFS_BUILD_CFG=$(cd $(dirname $ROOTFS_BUILD_CFG); pwd)/$(basename $ROOTFS_BUILD_CFG)

. $DIST_DIR/functions

. $ROOTFS_BUILD_CFG

ROOTFS=_install

if [ -d "$OUT_DIR/$VENDOR-rootfs.${TC_CFG}" ]; then
	run_with_check chmod -R +rw $OUT_DIR/$VENDOR-rootfs.${TC_CFG}
	run_with_check rm -rf $OUT_DIR/$VENDOR-rootfs.${TC_CFG}
fi

run_with_check mkdir -p $OUT_DIR/$VENDOR-rootfs.${TC_CFG}/$ROOTFS
run_with_check pushd $OUT_DIR/$VENDOR-rootfs.${TC_CFG}

#
# Install busybox
#
run_with_check tar vfx $OUT_DIR/$BUSYBOX.$TC_CFG._install.tar.gz

run_with_check cp -a $BUSYBOX.$TC_CFG._install/* $ROOTFS

#
# Install dropbear
#
run_with_check tar vfx $OUT_DIR/$DROPBEAR.$TC_CFG._install.tar.gz

run_with_check cp -a $DROPBEAR.$TC_CFG._install/* $ROOTFS

cp -a $PREFIX/$TC_CFG/sysroot/lib/ $ROOTFS
mkdir -p $ROOTFS/etc/dropbear
# FIXME: ~root == /
ROOT_SSH=$ROOTFS/.ssh
mkdir -p $ROOT_SSH
cp $DIST_DIR/keys/rsa_key.dropbear $ROOTFS/etc/dropbear/dropbear_rsa_host_key
cp $DIST_DIR/keys/rsa_key.pub $ROOT_SSH/authorized_keys
if [ -f "$PUBKEY" ]; then
	cat $PUBKEY >> $ROOT_SSH/authorized_keys
fi
chmod 400 $ROOTFS/etc/dropbear/dropbear_rsa_host_key $ROOT_SSH/authorized_keys
chmod 700 $ROOT_SSH

#
# Install kexec-tools
#
if [ "$KEXEC_TOOLS" != "" -a -f $OUT_DIR/$KEXEC_TOOLS.$TC_CFG._install.tar.gz ]; then
	run_with_check tar vfx $OUT_DIR/$KEXEC_TOOLS.$TC_CFG._install.tar.gz
	run_with_check cp -a $KEXEC_TOOLS.$TC_CFG._install/* $ROOTFS
fi

#
# Required files & dirs
#
run_with_check mkdir -p $ROOTFS/dev
run_with_check mkdir -p $ROOTFS/sys
run_with_check mkdir -p $ROOTFS/proc
run_with_check mkdir -p $ROOTFS/etc
echo "none  /proc     proc      defaults 0 0" >> $ROOTFS/etc/fstab
echo "none  /tmp      tmpfs     defaults 0 0" >> $ROOTFS/etc/fstab
echo "none  /sys      sysfs     defaults 0 0" >> $ROOTFS/etc/fstab
echo "none  /dev      devtmpfs  defaults 0 0" >> $ROOTFS/etc/fstab
echo "none  /dev/pts  devpts    defaults 0 0" >> $ROOTFS/etc/fstab
run_with_check mkdir -p $ROOTFS/tmp

mkdir -p $ROOTFS/etc/network/if-pre-up.d
mkdir -p $ROOTFS/etc/network/if-up.d
cat > $ROOTFS/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
       address 10.3.0.2
       netmask 255.255.255.0
       network 10.3.0.0
       broadcast 10.3.0.255
EOF

# FIXME: ~root == /
echo 'root:x:0:0:root:/:/bin/sh' > $ROOTFS/etc/passwd

( cd $ROOTFS ; ln -s tmp/var )
rm $ROOTFS/sbin/init
cat > $ROOTFS/sbin/init <<EOF
#!/bin/sh

export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin/:/sbin:/usr/sbin

echo
echo init started...
echo

echo mounting /proc ...
mount -n /proc
echo mounting /tmp ...
mount -n /tmp
mkdir /tmp/var
echo mounting /sys ...
mount -n /sys
echo mounting /dev ...
mount -n /dev
mkdir /dev/pts
echo mounting /dev/pts ...
mount -n /dev/pts

# sparc openprom
if grep openpromfs /proc/filesystems >/dev/null 2>/dev/null; then
	if [ -d /proc/openprom ]; then
		echo mounting /proc/openprom ...
		mount -n -t openpromfs none /proc/openprom
	fi
fi

mkdir -p /var/run
echo network interfaces ...
ifup -a
echo dropbear ssh server ...
dropbear
/bin/sh
EOF
chmod +x $ROOTFS/sbin/init

# Hm... mips roots does not need this, but x86 does
rm -f $ROOTFS/linuxrc
( cd $ROOTFS; ln -s sbin/init linuxrc )

# FIXME: ~root == /, so set permissions for dropbear
chmod 755 $ROOTFS

MKCRAMFS=$(which $MKCRAMFS)
MKSQUASHFS=$(which $MKSQUASHFS)

if [ -x $MKCRAMFS ]; then
	# FIXME: cramfs.img always big-endian
	run_with_check $MKCRAMFS -N big $ROOTFS cramfs.img
fi

if [ -x $MKSQUASHFS ]; then
	run_with_check $MKSQUASHFS $ROOTFS squashfs.img -noappend -all-root
fi

run_with_check chmod -R +rw $ROOTFS
run_with_check popd
