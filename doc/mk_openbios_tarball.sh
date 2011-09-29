#!/bin/sh

OPENBIOS_DIR=openbios.svn

SVN_REV=$(svn checkout svn://openbios.org/openbios/trunk/openbios-devel $OPENBIOS_DIR | grep "^Checked out revisio" | sed "s/^Checked out revision //;s/\.$//")
if [ "$?" != "0" ]; then
	echo "svn checkout error"
	exit 1
fi

rm -rf $OPENBIOS_DIR/.svn

OPENBIOS_NEW_NAME=openbios+svn$SVN_REV

mv $OPENBIOS_DIR $OPENBIOS_NEW_NAME

tar czf $OPENBIOS_NEW_NAME.tar.gz $OPENBIOS_NEW_NAME
rm -rf $OPENBIOS_NEW_NAME
