#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

distro=""
source zrythm-builds/scripts/common.sh.in

echo "sending $gnu_linux_zip_filename..."
$scp_cmd \
  "/tmp/artifacts/$gnu_linux_zip_filename" \
  "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_filename" > out.log 2> err.log
echo "done"

if is_tag ; then
  echo "sending $gnu_linux_zip_trial_filename..."
  $scp_cmd \
    "/tmp/artifacts/$gnu_linux_zip_trial_filename" \
    "$remote_ip:$remote_home/packages/gnu-linux/$gnu_linux_zip_trial_filename" > out.log 2> err.log
  echo "done"
fi
