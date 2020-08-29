#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

distro=$1
opt=$2
id_rsa_path=$(pwd)/id_rsa

source zrythm-builds/scripts/common.sh.in

makefile=zrythm-installer/Makefile
echo "replacing values in $makefile"
sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s/LOCALES=.*/LOCALES=$linguas/" $makefile
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
