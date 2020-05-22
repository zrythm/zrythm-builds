#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

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

# if arch, also deploy manuals
if [ "$distro" = "archlinux" ]; then
  for lang in $linguas ; do
    $scp_cmd \
      "zrythm-installer/build/zrythm-$zrythm_pkg_ver/build/doc/user/$lang/latex/Zrythm.pdf" \
      "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf"
  done
fi

# deploy plugins
if package_has_zplugins_dir $distro ; then
  $scp_cmd -r \
    zrythm-installer/$pkg_dirname/$distro/zplugins \
    $remote_ip:$remote_packages/$distro/
fi
