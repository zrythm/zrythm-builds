#! /bin/bash

set -e

makefile=zrythm-installer/Makefile

sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
PKG_VERSION=$(cd zrythm && printf "%s" "$(git describe --tags | sed 's/-/\.r/' | sed 's/v//g' | sed 's/-/\./')")
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s,/home/ansible,/home/build,g" $makefile
sed -i -e "s,ARCH_MXE_ROOT=.*,/home/build/mxe,g" $makefile
