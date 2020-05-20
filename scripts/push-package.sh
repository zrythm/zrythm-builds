#! /bin/bash

# this script pushes the given package to the server

set -e

# 1: package
# 2: distro

PACKAGE=$1
DISTRO=$2

SSH_OPTS="ssh -o StrictHostKeyChecking=no"
rsync --rsh="$SSH_OPTS" -rP $PACKAGE srht@forum.zrythm.org:/home/srht/packages/$DISTRO/
