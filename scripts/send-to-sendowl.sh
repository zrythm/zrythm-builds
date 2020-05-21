#! /bin/bash

source ~/.sendowl_credentials
source zrythm-builds/scripts/common.sh.in

# generic response holder
res_json=res.json

# current bundle
bundle_json=bundle.json

get_res () {
  suffix=$1
  curl -H "Accept: application/json" "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix" > res.json
  sleep 2
}

bundle_exists () {
}

fetch_bundle () {
  get_res "packages/search?term=$zrythm_pkg_ver"
  cat $res_file | jq '.[0].package' > $bundle_json && [ "$(cat $bundle_json)" != "null" ] || rm -rf $bundle_json
}

# check if a bundle already exists for this version
bundle_exists=0
curl -H "Accept: application/json" "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/packages/search?term=0.8.459" > packages.json
