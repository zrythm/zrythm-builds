#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

distro=$1
opt=$2
id_rsa_path=$(pwd)/id_rsa

source zrythm-builds/scripts/common.sh.in

makefile=zrythm-installer/Makefile
echo "replacing values in $makefile"
sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s,ARCH_MXE_ROOT=.*,ARCH_MXE_ROOT=$(pwd)/mxe,g" $makefile
sed -i -e "s,MXE_ZPLUGINS_CLONE_PATH=.*,MXE_ZPLUGINS_CLONE_PATH=$(pwd)/zplugins,g" $makefile
sed -i -e "s,MXE_GTK3_CLONE_PATH=.*,MXE_GTK3_CLONE_PATH=$(pwd)/gtk,g" $makefile
sed -i -e "s,BREEZE_DARK_PATH=.*,BREEZE_DARK_PATH=$(pwd)/breeze-icons/icons-dark,g" $makefile
sed -i -e "1,92s,/home/ansible,/home/build,g" $makefile
echo "done"

echo "fetching meson subprojects..."
if [ "$distro" = "archlinux" ] || [ "$distro" = "windows10" ]; then
  pushd zrythm
  meson subprojects download
  popd
  pushd zplugins
  meson subprojects download
  popd
fi

if [ "$distro" = "windows10" ]; then
  pushd gtk
  git checkout "3.24.18"
  meson subprojects download
  popd
fi
echo "done"

# skip if file already exists and not a tag
if should_skip_packaging $distro ; then
  echo "$distro package already exists on server, skipping..."
  exit 0 ;
fi

echo "$distro package does not exist on server, making..."
cd zrythm-installer
make $distro
