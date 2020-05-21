#! /bin/bash

# this script pushes the given GNU/Linux package to the server

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

# deploy normal package
$scp_cmd \
  zrythm-installer/$pkg_dirname/$distro/$pkg_filename \
  $remote_ip:$remote_packages/$distro/

# also deploy trial if tag
if is_tag ; then
  $scp_cmd \
    zrythm-installer/$pkg_dirname/$distro/$pkg_trial_filename \
    $remote_ip:$remote_packages/$distro/
fi

# deploy plugins
if [ "$distro" = "osx" ]; then
  $scp_cmd -r \
    zrythm-installer/$pkg_dirname/$distro/zplugins \
    $remote_ip:$remote_packages/$distro/
fi
