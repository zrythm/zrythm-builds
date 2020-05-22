#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

source zrythm-builds/scripts/common.sh.in

bundle_name="Zrythm $zrythm_pkg_ver"

sendowl_get () {
  suffix=$1
  sleep 2
  curl -H "Accept: application/json" \
    "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix"
}

sendowl_post () {
  suffix=$1
  json=$2
  sleep 2
  curl -X POST -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -d \'$json\'
    "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix"
}

# prefetch the installers
prefetch () {

}

fetch_or_create_bundle () {
  all_bundles="$(sendowl_get \"packages\")"

  this_bundle="null"
  i=0
  while true; do
    cur_bundle="$(echo \"$all_bundles\" | \
      jq \".[$i].package\" || echo \"null\")"
    if [ "$cur_bundle" = "null" ]; then
      break
    fi
    if [ $(echo "$cur_bundle" | jq '.name' || echo "null") = \
      "\"$bundle_name\"" ]; then
      this_bundle="$cur_bundle"
      break
    fi
    ((i++))
  done

  # create or update the products

  # if no bundle exists
  if [ "$this_bundle" = "null" ]; then
    # create one
    json="\
      { \
        \"package\": { \
          \"name\": \"$bundle_name\", \
          \"price\": \"5.00\", \
          \"price_is_minimum\": \"true\" \
          \"components\": { \
            \"product_ids\": $product_ids \
          } \
        } \
      }"
    this_bundle=$(sendowl_post "packages" $json)
  fi
}
