#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

distro=""
source zrythm-builds/scripts/common.sh.in

$scp_cmd \
  "zrythm-installer/$gnu_linux_zip_filename" \
  "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_filename"

if is_tag ; then
  $scp_cmd \
    "zrythm-installer/$gnu_linux_zip_trial_filename" \
    "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_trial_filename"
fi
