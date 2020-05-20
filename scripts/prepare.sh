#! /bin/bash

set -e

ZRYTHM_GIT_FETCH_DIR=zrythm
MAKEFILE=zrythm-installer/Makefile

sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $MAKEFILE
PKG_VERSION=$(cd $ZRYTHM_GIT_FETCH_DIR && printf "%s" "$(git describe --tags | sed 's/-/\.r/' | sed 's/v//g' | sed 's/-/\./')")
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$PKG_VERSION/" $MAKEFILE
sed -i -e "s,/home/ansible,/home/build,g" $MAKEFILE
