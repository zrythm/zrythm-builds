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
  >&2 echo "getting package $pkg_filename..."
  $scp_cmd \
    "$remote_ip:$remote_packages/$distro/$pkg_filename" \
    "$artifacts_distro_dir/$pkg_filename" > out.log 2> err.log
  if is_tag ; then
    >&2 echo "getting package $pkg_trial_filename..."
    $scp_cmd \
      "$remote_ip:$remote_packages/$distro/$pkg_trial_filename" \
      "$artifacts_distro_dir/$pkg_trial_filename" > out.log 2> err.log
  fi

  # get plugins
  if [ "$distro" != "gnu-linux" ]; then
    >&2 echo "getting plugins..."
    $scp_cmd -r $remote_ip:$remote_packages/$distro/zplugins \
      "$artifacts_distro_dir"/ > out.log 2> err.log
  fi
}

# wait for all packages to be submitted
echo "waiting for packages to be submitted..."
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
echo "fetching packages..."
for distro in $distros ; do
  wget_package_and_plugins $distro
done

# get manual
for lang in $linguas ; do
  echo "fetching $lang manual..."
  $scp_cmd \
    "$remote_ip:$remote_home/manual/Zrythm-$zrythm_pkg_ver-$lang.pdf" \
    "zrythm-installer/Zrythm-$zrythm_pkg_ver-$lang.pdf" > out.log 2> err.log
done

# make zip
echo "making $gnu_linux_zip_filename..."
make -C zrythm-installer $gnu_linux_zip_filename
if is_tag ; then
  echo "making $gnu_linux_zip_trial_filename..."
  make -C zrythm-installer \
    $gnu_linux_zip_trial_filename
fi
