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

distro=""
source zrythm-builds/scripts/common.sh.in

artifacts_dir="$(pwd)/zrythm-installer/artifacts"
mkdir -p $artifacts_dir
pdf_dir="$(pwd)/zrythm-installer/pdf"
mkdir -p $pdf_dir

echo "configuring zrythm-installer..."
meson_path="$(pwd)/meson/meson.py"
pushd zrythm-installer
$meson_path build --reconfigure -Dmeson-path=$meson_path \
  -Dzrythm-git-ver=master -Dzrythm-pkg-ver=$zrythm_pkg_ver \
  -Dbreeze-dark-path="$(pwd)/breeze-icons/icons-dark" -Ddistro=gnu-linux \
  -Dbuild-trial=false -Dpackages-dir=$artifacts_dir \
  -Dpdf-dir=$pdf_dir \
  --prefix=/tmp/artifacts
popd
echo "done"

wget_package_and_plugins () {
  distro=$1
  pkg_filename=$(get_package_filename $distro)
  pkg_trial_filename=$(get_package_filename $distro "-trial")

  artifacts_distro_dir="$artifacts_dir/$distro"
  mkdir -p "$artifacts_distro_dir"

  # get package
  >&2 echo "getting package $pkg_filename for $distro..."
  $scp_cmd \
    "$remote_ip:$remote_packages/$distro/$pkg_filename" \
    "$artifacts_distro_dir/$pkg_filename" > out.log 2> err.log
  >&2 echo "done"

  # get trial if tag
  if is_tag ; then
    >&2 echo "getting package $pkg_trial_filename for $distro..."
    $scp_cmd \
      "$remote_ip:$remote_packages/$distro/$pkg_trial_filename" \
      "$artifacts_distro_dir/$pkg_trial_filename" > out.log 2> err.log
    >&2 echo "done"
  fi
}

# wait for all packages to be submitted
echo "waiting for packages to be submitted..."
while true; do
  sleep 12
  wait_more=0
  for lang in $linguas ; do
    if ! remote_file_exists \
      "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" ; then
      echo "not exists" && wait_more=1
    fi
  done
  for distro in $distros ; do
    if [ "$distro" != "gnu-linux" ]; then
      echo "checking if remote pkg exists for $distro..."
      if ! remote_pkg_exists $distro ; then
        echo "not exists" && wait_more=1
      fi
      if is_tag ; then
        echo "checking if remote trial_pkg exists for $distro..."
        if ! remote_pkg_exists $distro "-trial"; then
          echo "not exists" && wait_more=1
        fi
      fi
    fi
  done
  if [ $wait_more -eq 0 ]; then
    break
  fi
done

# move packages/plugins to where they are expected
echo "fetching packages..."
for distro in $distros ; do
  if [ "$distro" != "gnu-linux" ]; then
    echo "fetching packages and plugins for $distro..."
    wget_package_and_plugins $distro
  fi
done

# get manuals
for lang in $linguas ; do
  echo "fetching $lang manual..."
  $scp_cmd \
    "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    "$pdf_dir/Zrythm-$zrythm_pkg_ver-$lang.pdf" > out.log 2> err.log
done

# make zip
echo "making $gnu_linux_zip_filename..."
pushd zrythm-installer
ninja -C build install
echo "done"
if is_tag ; then
  echo "making $gnu_linux_zip_trial_filename..."
  $meson_path build --reconfigure -Dbuild-trial=true
  ninja -C build install
  echo "done"
fi
popd
