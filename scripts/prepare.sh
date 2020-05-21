#! /bin/bash

set -euo pipefail

makefile=zrythm-installer/Makefile

source zrythm-builds/scripts/common.sh.in

sed -i -e "s/ZRYTHM_VERSION=.*/ZRYTHM_VERSION=master/" $makefile
sed -i -e "s/ZRYTHM_PKG_VERSION=.*/ZRYTHM_PKG_VERSION=$zrythm_pkg_ver/" $makefile
sed -i -e "s,/home/ansible,/home/build,g" $makefile
sed -i -e "s,ARCH_MXE_ROOT=.*,ARCH_MXE_ROOT=/home/build/mxe,g" $makefile
