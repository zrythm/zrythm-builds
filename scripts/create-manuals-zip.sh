#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>
#
# This script creates the manuals zip (used by the windows
# build)

distro=windows10
source zrythm-builds/scripts/common.sh.in

mkdir -p zrythm-installer/build
for lang in $linguas ; do
  $scp_cmd \
    "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    zrythm-installer/build/Zrythm-$zrythm_pkg_ver-$lang.pdf
done
pushd "zrythm-installer/build"
zip user-manual.zip ./*.pdf
popd
