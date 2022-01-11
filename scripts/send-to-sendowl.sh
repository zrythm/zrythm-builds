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

echo "bundle: $zrythm_pkg_semver"

products_api_endpoint="https://accounts.zrythm.org/api/v1/products/"
authorization_str="Authorization: Token $ZRYTHM_ACCOUNTS_TOKEN"

# get a product
product_get () {
  suffix=$1
  sleep 2
  curl -X GET \
    -H "Accept: application/json" \
    -H "$authorization_str" \
    "$products_api_endpoint$suffix"
}

# create a new product
product_post_json () {
  json="$1"
  sleep 2
  >&2 echo "POST $json"
  curl -X POST \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -H "$authorization_str" \
    -d "$json" \
    "$products_api_endpoint" > out.log 2> err.log
}

# creates a product and returns the json
create_product ()
{
  if is_tag ; then
    type_name="Single"
    summary="Single version"
    description="<center> You will get an installer that works with the following distros/OSes:<br> <b>Arch Linux - <i>x86_64</i></b><br> <b>Debian 11 & 12 - <i>amd64</i></b><br> <b>Fedora 34 & 35 - <i>x86_64</i></b><br> <b>Ubuntu 20.04 & 21.10 - <i>amd64</i></b><br> <b>GNU/Linux - AppImage (experimental) <i>x86_64</i></b><br> <b>Windows 10 - <i>64-bit</i></b><br> <b>MacOS 10.15 (Catalina)</b><br><br> The installer includes the PDF user manual in:<br> <b>English, French, Portuguese, Italian, Japanese and German</b><br><br> plus the following optional bundled plugins:<br> <b>ZChordz, ZCompressorSP, ZLimiterSP, ZLFO, ZPhaserSP, ZSaw, ZVerbSP</b> </center>"
  else
    type_name="Nightly"
    summary="Nightly build"
    description="Nightly build at $(date)."
  fi

  product_post_json \
    "{\"type\": \"$type_name\", \"summary\": \"$summary\", \"description\": \"$description\", \"version\": \"$zrythm_pkg_semver\", \"image_url\": \"https://www.zrythm.org/static/icons/zrythm/z_frame_8.png\", \"price_gbp\": \"5.00\"}"
}

# prefetch the installers not on this machine
prefetch () {
  osx_pkg_name="$(get_package_filename osx-brew-zip)"
  windows_pkg_name="$(get_package_filename windows10-msys)"
  gnu_linux_pkg_name="$(get_package_filename gnu-linux)"
  appimage_pkg_name="$(get_package_filename appimage)"
  while ! [ -f "zrythm-installer/$osx_pkg_name" -a \
    -f "zrythm-installer/$windows_pkg_name" -a  \
    -f "zrythm-installer/$appimage_pkg_name" -a  \
    -f "zrythm-installer/$gnu_linux_pkg_name" ]; do
    >&2 echo "$osx_pkg_name or $windows_pkg_name or $gnu_linux_pkg_name $appimage_pkg_name don't exist. fetching..."
    fetch_file \
      "packages/osx-brew-zip/$osx_pkg_name" \
      "zrythm-installer/$osx_pkg_name" || true
    fetch_file \
      "packages/windows10-msys/$windows_pkg_name" \
      "zrythm-installer/$windows_pkg_name" || true
    fetch_file \
      "packages/gnu-linux/$gnu_linux_pkg_name" \
      "zrythm-installer/$gnu_linux_pkg_name" || true
    fetch_file \
      "packages/appimage/$appimage_pkg_name" \
      "zrythm-installer/$appimage_pkg_name" || true
    sleep 24
  done
}

# fetch missing installers
echo "prefetching installers..."
prefetch
echo "done"

# create product (if fail, it means the product already exists - do nothing)
echo "creating product..."
create_product
echo "done"
