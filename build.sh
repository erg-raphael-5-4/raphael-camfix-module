#!/bin/bash
# Zip module/ into out/raphael-camfix-<version>.zip.
set -e
cd "$(dirname "$0")"
[ -f module/system/priv-app/MiuiCamera/MiuiCamera.apk ] || src/build-apk.sh
ver=$(sed -n 's/^version=//p' module/module.prop)
mkdir -p out
rm -f "out/raphael-camfix-$ver.zip"
(cd module && zip -qr "../out/raphael-camfix-$ver.zip" .)
echo "out/raphael-camfix-$ver.zip"
