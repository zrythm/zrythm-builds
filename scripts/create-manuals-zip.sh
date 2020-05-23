#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>
#
# This script creates the manuals zip (used by the windows
# build)

distro=windows10
source zrythm-builds/scripts/common.sh.in

echo "fetching manuals from server..."

mkdir -p zrythm-installer/build
while true; do
  sleep 12
  wait_more=0
  for lang in $linguas ; do
    echo "checking if $lang manual exists..."
    remote_file_exists \
      "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" || \
      wait_more=1
  done
  if [ $wait_more -eq 0 ]; then
    break
  fi
done

for lang in $linguas ; do
  echo "fetching $lang manual..."
  $scp_cmd \
    "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    zrythm-installer/build/Zrythm-$zrythm_pkg_ver-$lang.pdf > out.log 2> err.log
done

echo "zipping manuals..."
pushd "zrythm-installer/build"
zip user-manual.zip ./*.pdf
popd
