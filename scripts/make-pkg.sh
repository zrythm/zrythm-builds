#! /bin/bash

distro=$1
id_rsa_path=$(pwd)/id_rsa

source zrythm-builds/scripts/common.sh.in

makefile=zrythm-installer/Makefile
sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s,/home/ansible,/home/build,g" $makefile
sed -i -e "s,ARCH_MXE_ROOT=.*,ARCH_MXE_ROOT=$(pwd)/mxe,g" $makefile
sed -i -e "s,MXE_ZPLUGINS_CLONE_PATH=.*,MXE_ZPLUGINS_CLONE_PATH=$(pwd)/zplugins,g" $makefile
sed -i -e "s,MXE_GTK3_CLONE_PATH=.*,MXE_GTK3_CLONE_PATH=$(pwd)/gtk,g" $makefile
sed -i -e "s,BREEZE_DARK_PATH=.*,BREEZE_DARK_PATH=$(pwd)/breeze-icons/icons-dark,g" $makefile

$(cd "$(pwd)/zplugins" && meson subprojects download)
$(cd "$(pwd)/gtk" && git checkout "3.24.18" && meson subprojects download)

# skip if file already exists and not a tag
source zrythm-builds/scripts/common.sh.in
if should_skip_packaging $distro ; then
  exit 0 ;
fi

cd zrythm-installer
make $distro
