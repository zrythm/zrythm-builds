#! /bin/bash

# this script pushes the given GNU/Linux package to the server

set -eo pipefail

DISTRO=$1

source zrythm-builds/scripts/common.sh.in

pkg_filename=$(get_package_filename $DISTRO)
pkg_trial_filename=$(get_package_filename $DISTRO "-trial")

# deploy normal package
$RSYNC \
  -rP zrythm-installer/build/$DISTRO/$pkg_filename \
  $REMOTE_IP:$REMOTE_PACKAGES/$DISTRO/

# also deploy trial if tag
if is_tag ; then
  $RSYNC \
    -rP zrythm-installer/build/$DISTRO/$pkg_trial_filename \
    $REMOTE_IP:$REMOTE_PACKAGES/$DISTRO/
fi

# deploy plugins
$SCP -r \
  zrythm-installer/build/$DISTRO/zplugins \
  $REMOTE_IP:$REMOTE_PACKAGES/$DISTRO/
