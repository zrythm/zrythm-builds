#! /bin/bash

source zrythm-builds/scripts/common.sh.in

$RSYNC -rP zrythm-installer/zrythm
if is_tag ; then
