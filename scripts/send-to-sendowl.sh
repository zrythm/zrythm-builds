#! /bin/bash

source ~/.sendowl_credentials
source zrythm-builds/scripts/common.sh.in

res_file=res.json

get_res () {
  suffix=$1
  curl -H "Accept: application/json" "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix" > res.json
  sleep 2
}

bundle_exists () {
  get_res "packages/search?term=$zrythm_pkg_ver"
  cat $res_file | jq '.[0]' && return 1 || return 0
}

# check if a bundle already exists for this version
bundle_exists=0
curl -H "Accept: application/json" "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/packages/search?term=0.8.459" > packages.json
