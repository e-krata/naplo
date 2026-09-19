#!/bin/sh
set -e

# Hibás submodule ne zavarjon
rm -rf filcnaplo_premium 2>/dev/null || true

pub_get() {
  dir="$1"
  if [ -f "$dir/pubspec.yaml" ]; then
    echo "==> $dir"
    (cd "$dir" && flutter clean && flutter pub get)
  else
    echo "==> SKIP $dir (nincs pubspec.yaml)"
  fi
}

# Sorrend: előbb a path-függőségek, aztán a fő app
pub_get "naplo_premium"
pub_get "filcnaplo_kreta_api"
pub_get "filcnaplo_mobile_ui"
pub_get "filcnaplo_desktop_ui"
pub_get "filcnaplo"

echo "Fixed pub."