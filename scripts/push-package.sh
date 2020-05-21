#! /bin/bash

# this script pushes the given GNU/Linux package to the server

distro=$1

source zrythm-builds/scripts/common.sh.in

# skip if file already exists and not a tag
if should_skip_packaging $distro ; then
  exit 0 ;
fi

pkg_filename=$(get_package_filename $distro)
pkg_trial_filename=$(get_package_filename $distro "-trial")

# deploy normal package
$rsync_cmd \
  -rP zrythm-installer/build/$distro/$pkg_filename \
  $remote_ip:$remote_packages/$distro/

# also deploy trial if tag
if is_tag ; then
  $rsync_cmd \
    -rP zrythm-installer/build/$distro/$pkg_trial_filename \
    $remote_ip:$remote_packages/$distro/
fi

# deploy plugins
$scp_cmd -r \
  zrythm-installer/build/$distro/zplugins \
  $remote_ip:$remote_packages/$distro/
