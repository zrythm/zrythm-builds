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

echo "configuring zrythm-installer..."
meson_path="$(pwd)/meson/meson.py"
pushd zrythm-installer
# TODO linguas
$meson_path build -Dmeson-path=$meson_path \
  -Dzrythm-git-ver=master -Dzrythm-pkg-ver=$zrythm_pkg_ver \
  -Dbreeze-dark-path="$(pwd)/breeze-icons/icons-dark" -Ddistro=$distro \
  -Dbuild-trial=false --prefix=/tmp/artifacts/$distro
popd
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
pushd zrythm-installer
ninja -C build install
if is_tag ; then
  $meson_path build --reconfigure -Dbuild-trial=true
  ninja -C build install
fi
popd
