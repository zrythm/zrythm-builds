#! /bin/bash

set -e

source zrythm-builds/scripts/common.sh.in

# returns if the file exists
file_exists () {
  $SSH $REMOTE_IP [[ -f "$REMOTE_HOME/$1" ]]
}

# macro to check if package exists
package_exists () {
  distro=$1
  pkg_type=$(distro_to_pkg_type $distro)
  file_exists packages/$distro/$(get_package_filename $pkg_type)
}

wget_package_and_plugins () {
  distro=$1
  pkg_type=$(distro_to_pkg_type $distro)
  pkg_filename=$(get_package_filename $pkg_type)
  pkg_trial_filename=$(get_package_filename $pkg_type "-trial")

  # get package
  $SCP $REMOTE_IP:$REMOTE_PACKAGES/$distro/$pkg_filename \
    zrythm-installer/artifacts/$distro/
  if is_tag ; then
    $SCP \
      $REMOTE_IP:$REMOTE_PACKAGES/$distro/$pkg_trial_filename \
      zrythm-installer/artifacts/$distro/
  fi

  # get plugins
  $SCP -r $REMOTE_IP:$REMOTE_PACKAGES/$distro/zplugins \
    zrythm-installer/artifacts/$distro/
}

# wait for all packages to be submitted
while [ true ]
do
  sleep 12
  for lang in $LINGUAS ; do
    file_exists \
      "manual/Zrythm-$ZRYTHM_PKG_VERSION-$lang.pdf" || \
      continue
  done
  for distro in $DISTROS ; do
    package_exists $distro || continue
  done
  break
done

# move packages/plugins to where they are expected
for distro in $DISTROS ; do
  wget_package_and_plugins $distro
done

# get manual
for lang in $LINGUAS ; do
  $SCP \
    "$REMOTE_IP:$REMOTE_HOME/manual/Zrythm-$ZRYTHM_PKG_VERSION-$lang.pdf" \
    zrythm-installer/
done

# make zip
make -C zrythm-installer \
  zrythm-$ZRYTHM_PKG_VERSION-installer.zip
if is_tag ; then
  make -C zrythm-installer \
    zrythm-trial-$ZRYTHM_PKG_VERSION-installer.zip
fi
