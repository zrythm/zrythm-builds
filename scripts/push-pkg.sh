#! /bin/bash
#
# Copyright (C) 2020-2022 Alexandros Theodotou <alex at zrythm dot org>
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

set -ex

distro=$1
id_rsa_path=$(pwd)/id_rsa

source zrythm-builds/scripts/common.sh.in

pkg_filename=$(get_package_filename $distro)
pkg_trial_filename=$(get_package_filename $distro "-trial")
pkg_dirname="build"
if [ "$distro" = "osx" ]; then
  pkg_dirname="artifacts"
fi

# skip if file already exists and not a tag
# (no skipping for manual PDFs)
if [ "$distro" = "user-manual-pdfs" ]; then
  exists=1
  for lang in $linguas ; do
    echo "checking if $lang manual exists..."
    if remote_file_exists "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" "$connection_type_aws"; then
      >&2 echo "found"
    else
      >&2 echo "does not exist"
      exists=0
      break
    fi
  done
  if [ $exists -eq 1 ]; then
    echo "PDF manuals already exist - skipping"
    exit 0 ;
  fi
elif should_skip_packaging $distro "$deploy_connection_type" ; then
  exit 0 ;
fi

deploy_pkg () {
  filename=$1
  connection_type=$2
  src_file="/tmp/artifacts/$distro/$filename"
  echo "deploying package for $distro ($src_file)..."
  if send_file \
    "$src_file" "packages/$distro/$filename" \
    "$connection_type" ; then
    echo "succeeded"
  else
    echo >&2 "failed: $(cat out.log)"
    echo >&2 "$(cat err.log)"
    exit 1
  fi
  echo "done"
}

# deploy manuals if building user-manual-pdfs
if [ "$distro" = "user-manual-pdfs" ]; then
  for lang in $linguas ; do
    echo "deploying $lang manual..."
    send_file \
      "zrythm-installer/build/arch/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
      "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
      "$connection_type_aws"
    echo "done"
  done
else
  # deploy normal package
  deploy_pkg "$pkg_filename" "$deploy_connection_type"

  # also deploy trial if tag
  if is_tag && [[ "$distro" != "user-manual-zip" ]]; then
    echo "deploying trial package"
    deploy_pkg "$pkg_trial_filename" "$connection_type_aws"
    #add_file_tag "packages/$distro/$pkg_trial_filename" \
      #"public" "yes"
  fi
fi
