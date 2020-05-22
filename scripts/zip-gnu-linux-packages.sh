#! /bin/bash

distro=""
source zrythm-builds/scripts/common.sh.in

artifacts_dir="zrythm-installer/artifacts"
mkdir -p $artifacts_dir

sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" zrythm-installer/Makefile

wget_package_and_plugins () {
  distro=$1
  pkg_filename=$(get_package_filename $distro)
  pkg_trial_filename=$(get_package_filename $distro "-trial")

  artifacts_distro_dir="$artifacts_dir/$distro"
  mkdir -p "$artifacts_distro_dir"

  # get package
  $scp_cmd \
    "$remote_ip:$remote_packages/$distro/$pkg_filename" \
    "$artifacts_distro_dir/$pkg_filename"
  if is_tag ; then
    $scp_cmd \
      "$remote_ip:$remote_packages/$distro/$pkg_trial_filename" \
      "$artifacts_distro_dir/$pkg_trial_filename"
  fi

  # get plugins
  $scp_cmd -r $remote_ip:$remote_packages/$distro/zplugins \
    "$artifacts_distro_dir"/
}

# wait for all packages to be submitted
while true; do
  sleep 12
  for lang in $linguas ; do
    remote_file_exists \
      "manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" || \
      continue
  done
  for distro in $distros ; do
    remote_pkg_exists $distro || continue
  done
  break
done

# move packages/plugins to where they are expected
for distro in $distros ; do
  wget_package_and_plugins $distro
done

# get manual
for lang in $linguas ; do
  $scp_cmd \
    "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    "zrythm-installer/Zrythm-$zrythm_pkg_ver-$lang.pdf"
done

# make zip
make -C zrythm-installer $gnu_linux_zip_filename
if is_tag ; then
  make -C zrythm-installer \
    $gnu_linux_zip_trial_filename
fi
