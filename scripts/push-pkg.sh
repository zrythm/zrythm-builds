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

# this script pushes the given package/installer to the server

distro=$1
id_rsa_path=$(pwd)/id_rsa

source zrythm-builds/scripts/common.sh.in

# skip if file already exists and not a tag
if should_skip_packaging $distro ; then
  exit 0 ;
fi

pkg_filename=$(get_package_filename $distro)
pkg_trial_filename=$(get_package_filename $distro "-trial")
pkg_dirname="build"
if [ "$distro" = "osx" ]; then
  pkg_dirname="artifacts"
fi

deploy_pkg () {
  filename=$1
  echo "deploying package for $distro (/tmp/artifacts/$distro/$filename)..."
  if $scp_cmd \
    /tmp/artifacts/$distro/$filename \
    $remote_ip:$remote_packages/$distro/$filename > out.log 2> err.log ; then
    echo "succeeded"
  else
    echo >&2 "failed: $(cat out.log)"
    echo >&2 "$(cat err.log)"
  fi
  echo "done"
}

# deploy normal package
deploy_pkg "$pkg_filename"

# also deploy trial if tag
if is_tag ; then
  echo "deploying trial package"
  deploy_pkg "$pkg_trial_filename"
fi

# if arch, also deploy manuals
if [ "$distro" = "archlinux" ]; then
  for lang in $linguas ; do
    echo "deploying $lang manual..."
    $scp_cmd \
      "zrythm-installer/build/arch/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
      "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" > out.log 2> err.log
    echo "done"
  done
fi
