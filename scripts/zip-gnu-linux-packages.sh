#! /bin/bash

set -e

source zrythm-builds/scripts/common.sh.in

wget_package_and_plugins () {
  distro=$1
  pkg_type=$(distro_to_pkg_type $distro)
  pkg_filename=$(get_package_filename $pkg_type)
  pkg_trial_filename=$(get_package_filename $pkg_type "-trial")

  # get package
  $scp_cmd $remote_ip:$remote_packages/$distro/$pkg_filename \
    zrythm-installer/artifacts/$distro/
  if is_tag ; then
    $scp_cmd \
      $remote_ip:$remote_packages/$distro/$pkg_trial_filename \
      zrythm-installer/artifacts/$distro/
  fi

  # get plugins
  $scp_cmd -r $remote_ip:$remote_packages/$distro/zplugins \
    zrythm-installer/artifacts/$distro/
}

# wait for all packages to be submitted
while [ true ]
do
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
    zrythm-installer/
done

# make zip
make -C zrythm-installer \
  zrythm-$zrythm_pkg_ver-installer.zip
if is_tag ; then
  make -C zrythm-installer \
    zrythm-trial-$zrythm_pkg_ver-installer.zip
fi
