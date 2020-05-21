#! /bin/bash

set -euo pipefail

distro=$1

source zrythm-builds/scripts/common.sh.in

# skip if file already exists and not a tag
source zrythm-builds/scripts/common.sh.in
if should_skip_packaging $distro ; then
  exit 0 ;
fi

zrythm-builds/scripts/prepare.sh
cd zrythm-installer
make $distro
