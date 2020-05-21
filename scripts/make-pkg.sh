#! /bin/bash

distro=$1

source zrythm-builds/scripts/common.sh.in

makefile=zrythm-installer/Makefile
sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s,/home/ansible,/home/build,g" $makefile
sed -i -e "s,ARCH_MXE_ROOT=.*,ARCH_MXE_ROOT=/home/build/mxe,g" $makefile

# skip if file already exists and not a tag
source zrythm-builds/scripts/common.sh.in
if should_skip_packaging $distro ; then
  exit 0 ;
fi

cd zrythm-installer
make $distro
