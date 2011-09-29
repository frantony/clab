#!/bin/sh

SEABIOS_DIR=seabios.git

git clone git://git.seabios.org/seabios.git $SEABIOS_DIR

#pushd $SEABIOS_DIR
cd $SEABIOS_DIR

#SEABIOS_VERSION=$(git tag | sort -n | tail -n 1 | sed "s/^rel-//")
SEABIOS_DATA=$(date -d "$(git log | head -n 3 | grep ^Date:  | sed 's/^Date:[ ]*//;s/[+-][0-9]*$//')" +%Y%m%d)

#popd
cd ..

#seabios-$SEABIOS_VERSION+git$SEABIOS_DATA
SEABIOS_NEW_NAME=seabios+git$SEABIOS_DATA

rm -rf $SEABIOS_DIR/.git
mv $SEABIOS_DIR $SEABIOS_NEW_NAME
tar czf $SEABIOS_NEW_NAME.tar.gz $SEABIOS_NEW_NAME
rm -rf $SEABIOS_NEW_NAME
