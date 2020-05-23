#! /bin/bash
#
# Copyright (C) 2020 Alexandros Theodotou <alex at zrythm dot org>

distro=""
source zrythm-builds/scripts/common.sh.in

bundle_name="Zrythm $zrythm_pkg_ver"
echo "bundle name: $bundle_name"

get_product_name () {
  os=$1
  case "$os" in
    "gnu-linux")
      echo "$bundle_name (GNU/Linux)"
      ;;
    "windows"*)
      echo "$bundle_name (Windows 64bit)"
      ;;
    "osx")
      echo "$bundle_name (MacOS)"
      ;;
  esac
}

sendowl_get () {
  suffix=$1
  sleep 2
  curl -H "Accept: application/json" \
    "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix"
}

sendowl_post_or_put_json () {
  suffix="$1"
  json="$2"
  protocol="$3"
  sleep 2
  curl -X $protocol -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -d "$json" \
    "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix"
}

sendowl_post_json () {
  sendowl_post_or_put_json "$1" "$2" POST
}

sendowl_put_json () {
  sendowl_post_or_put_json "$1" "$2" PUT
}

sendowl_post_form () {
  suffix=$1
  shift
  sleep 2
  cmd="curl -H \"Accept: application/json\" \
    https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix "
  for arg; do
    cmd="$cmd -F \"$arg\""
  done
  eval "$cmd"
}

sendowl_delete () {
  suffix=$1
  sleep 2
  curl -X DELETE -H "Accept: application/json" \
    "https://$SENDOWL_KEY:$SENDOWL_SECRET@www.sendowl.com/api/v1/$suffix"
}

# prefetch the installers not on this machine
prefetch () {
  osx_pkg_name="$(get_package_filename osx)"
  windows_pkg_name="$(get_package_filename windows10)"
  while ! [ -f "zrythm-installer/$osx_pkg_name" -a \
    -f "zrythm-installer/$windows_pkg_name" ]; do
    $scp_cmd \
      "$remote_ip:$remote_home/packages/osx/$osx_pkg_name" \
      "zrythm-installer/$osx_pkg_name" || true
    $scp_cmd \
      "$remote_ip:$remote_home/packages/windows10/$windows_pkg_name" \
      "zrythm-installer/$windows_pkg_name" || true
    sleep 12
  done
}

# creates a product and returns the json
create_product ()
{
  os=$1
  sendowl_post_form \
    "products" \
    "product[name]=$(get_product_name $os)" \
    "product[product_type]=digital" \
    "product[price]=5.00" \
    "product[attachment]=@$(pwd)/zrythm-installer/$(get_package_filename $os)" | jq '.product'
}

# creates or updates a product for the given type
# and returns the product ID
create_or_update_product () {
  os=$1
  all_products="$(sendowl_get products)"

  this_product="null"
  i=0
  while true; do
    cur_product=$(echo $all_products | \
      jq ".[$i].product" || echo "null")
    if [ "$cur_product" = "null" ]; then
      break
    fi
    if [ "$(echo "$cur_product" | jq '.name' || \
      echo null)" = \
      "\"$(get_product_name $os)\"" ]; then
      this_product="$cur_product"
      break
    fi
    ((i++))
  done

  # delete product if it exists
  if [ "$this_product" != "null" ]; then
    product_id="$(echo "$this_product" | jq '.id')"
    sendowl_delete "products/$product_id"
  fi

  # create one
  this_product="$(create_product $os)"

  echo "$this_product" | jq '.id'
}

update_or_create_bundle () {
  # create bundles on releases manually
  return

  gnu_linux_product_id=$1
  osx_product_id=$2
  windows_product_id=$3

  all_bundles="$(sendowl_get packages)"
  this_bundle="null"
  i=0
  while true; do
    cur_bundle="$(echo "$all_bundles" | \
      jq ".[$i].package" || echo "null")"
    if [ "$cur_bundle" = "null" ]; then
      break
    fi
    if [ "$(echo "$cur_bundle" | jq '.name' || echo "null")" = \
      "\"$bundle_name\"" ]; then
      this_bundle="$cur_bundle"
      break
    fi
    ((i++))
  done

  # prepare json
  json="\
    { \
      \"package\": { \
        \"name\": \"$bundle_name\", \
        \"price\": \"5.00\", \
        \"price_is_minimum\": \"true\" \
        \"components\": { \
          \"product_ids\": \"[$gnu_linux_product_id, $osx_product_id, $windows_product_id]\" \
        } \
      } \
    }"

  # create or update bundle
  if [ "$this_bundle" != "null" ]; then
    # update
    bundle_id="$(echo "$this_bundle" | jq '.id')"
    sendowl_put_json "packages/$bundle_id" "$json"
  else
    # create
    this_bundle="$(sendowl_post_json packages "$json" | \
      jq '.package')"
  fi

  echo "$this_bundle" | jq '.id'
}

# fetch missing installers
echo "prefetching installers..."
prefetch
echo "done"

# create or update products
echo "creating products..."
gnu_linux_product_id="$(create_or_update_product "gnu-linux")"
osx_product_id="$(create_or_update_product "osx")"
windows_product_id="$(create_or_update_product "windows10")"
echo "done"

echo "created products $gnu_linux_product_id, $osx_product_id and $windows_product_id"

bundle_id="$(update_or_create_bundle \
  "$gnu_linux_product_id" \
  "$osx_product_id" \
  "$windows_product_id")"
