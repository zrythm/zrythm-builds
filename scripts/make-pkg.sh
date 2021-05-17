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

echo "setting paths..."
set +u
if [ "$MESON_PATH" = "" ]; then
  meson_path="$(pwd)/meson/meson.py"
else
  meson_path="$MESON_PATH"
fi
if [ "$NINJA_PATH" = "" ]; then
  ninja_path=ninja
else
  ninja_path="$NINJA_PATH"
fi
set -u

echo "configuring zrythm-installer..."
parent_dir=$(pwd)
pushd zrythm-installer
reconfigure=
if [ -d "build" ]; then
  reconfigure="--reconfigure"
fi
_locales=`join_by , $linguas`
zrythm_git_ver="$(git ls-remote https://git.zrythm.org/zrythm/zrythm HEAD | awk '{print $1;}')"
$meson_path build $reconfigure -Dmeson-path=$meson_path \
  -Dzrythm-git-ver=$zrythm_git_ver -Dzrythm-pkg-ver=$zrythm_pkg_ver \
  -Dbreeze-dark-path="$parent_dir/breeze-icons/icons-dark" -Ddistro=$distro \
  -Dbuild-trial=false -Dmanuals-zip-file=$(pwd)/user-manual.zip \
  -Dlocales="$_locales" \
  --prefix=/tmp/artifacts/$distro
popd
echo "done"

if ! [ "$opt" = "" ]; then
  echo "calling $opt on $distro..."
  pushd zrythm-installer
  $ninja_path -C build "$opt"
  popd
  echo "returning..."
  exit 0
fi

echo "fetching meson subprojects..."
if [ "$distro" = "archlinux" ] || [ "$distro" = "windows10" ]; then
  pushd zrythm
  meson subprojects download || true
  popd
  pushd zplugins
  meson subprojects download || true
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
$ninja_path -C build install
if is_tag ; then
  echo "tag detected, building trial..."
  $meson_path build --reconfigure -Dbuild-trial=true
  $ninja_path -C build install
else
  echo "no tag detected, not building trial..."
fi
popd
