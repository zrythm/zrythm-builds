#! /bin/bash

# this script pushes the given GNU/Linux package to the server

set -eo pipefail

distro=$1

source zrythm-builds/scripts/common.sh.in

# skip if file already exists and not a tag
if should_skip_packaging $distro ; then
  exit 0 ;
fi

pkg_filename=$(get_package_filename $distro)
pkg_trial_filename=$(get_package_filename $distro "-trial")

# deploy normal package
$RSYNC \
  -rP zrythm-installer/build/$distro/$pkg_filename \
  $REMOTE_IP:$REMOTE_PACKAGES/$distro/

# also deploy trial if tag
if is_tag ; then
  $RSYNC \
    -rP zrythm-installer/build/$distro/$pkg_trial_filename \
    $REMOTE_IP:$REMOTE_PACKAGES/$distro/
fi

# deploy plugins
$SCP -r \
  zrythm-installer/build/$distro/zplugins \
  $REMOTE_IP:$REMOTE_PACKAGES/$distro/
