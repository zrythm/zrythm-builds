#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

distro=""
source zrythm-builds/scripts/common.sh.in

$scp_cmd \
  echo "sending $gnu_linux_zip_filename..."
  "zrythm-installer/$gnu_linux_zip_filename" \
  "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_filename" > out.log 2> err.log
echo "done"

if is_tag ; then
  echo "sending $gnu_linux_zip_trial_filename..."
  $scp_cmd \
    "zrythm-installer/$gnu_linux_zip_trial_filename" \
    "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_trial_filename" > out.log 2> err.log
  echo "done"
fi
