#!/bin/sh
set -e

rm -rf filcnaplo_premium 2>/dev/null || true

# Path package-ek: dart pub get (nincs Android embedding check)
pub_get_pkg() {
  dir="$1"
  if [ -f "$dir/pubspec.yaml" ]; then
    echo "==> $dir (dart pub get)"
    (cd "$dir" && dart pub get)
  else
    echo "==> SKIP $dir"
  fi
}

# Fő app: flutter pub get
pub_get_app() {
  dir="$1"
  if [ -f "$dir/pubspec.yaml" ]; then
    echo "==> $dir (flutter pub get)"
    (cd "$dir" && flutter clean && flutter pub get)
  else
    echo "==> SKIP $dir"
  fi
}

pub_get_pkg "naplo_premium"
pub_get_pkg "filcnaplo_kreta_api"
pub_get_pkg "filcnaplo_mobile_ui"
pub_get_pkg "filcnaplo_desktop_ui"
pub_get_app "filcnaplo"

echo "Fixed pub."