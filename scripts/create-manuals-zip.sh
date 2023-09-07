#! /bin/bash
#
# Copyright (C) 2020, 2022 Alexandros Theodotou <alex at zrythm dot org>
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

# This script creates the manuals zip

distro=$1
id_rsa_path="$(pwd)/id_rsa"
source zrythm-builds/scripts/common.sh.in

dest_path="$2"

echo "fetching manuals from server..."

mkdir -p "$dest_path"
while true; do
  sleep 12
  wait_more=0
  for lang in $linguas ; do
    echo "checking if $lang manual exists..."
    if remote_file_exists "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" "$deploy_connection_type"; then
      >&2 echo "found"
    else
      >&2 echo "does not exist"
      wait_more=1
    fi
  done
  if [ $wait_more -eq 0 ]; then
    break
  fi
done

for lang in $linguas ; do
  echo "fetching $lang manual..."
  fetch_file "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    "$dest_path/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    "$deploy_connection_type"
  echo "done"
done

echo "zipping manuals..."
pkg_filename=$(get_package_filename user-manual)
pushd "$dest_path"
zip "$pkg_filename" ./*.pdf
popd
echo "done"
