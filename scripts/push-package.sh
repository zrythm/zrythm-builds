#! /bin/bash

# this script pushes the given package to the server

set -e

DISTRO=$1

source zrythm-builds/scripts/common.sh.in

pkg_filename=$(get_package_filename $DISTRO)
pkg_trial_filename=$(get_package_filename $DISTRO "-trial")

# push normal package
$RSYNC \
  -rP zrythm-installer/build/$DISTRO/$pkg_filename \
  $REMOTE_IP:$REMOTE_PACKAGES/$DISTRO/

# if version contains r (revision), push trial
if $is_tag ; then
  $RSYNC \
    -rP zrythm-installer/build/$DISTRO/$pkg_trial_filename \
    $REMOTE_IP:$REMOTE_PACKAGES/$DISTRO/
fi
