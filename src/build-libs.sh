#!/bin/bash
# Build the shims and patch the blobs they hook into.
#   TOP=<derp-17 tree> src/build-libs.sh
set -e
cd "$(dirname "$0")/.."
TOP="${TOP:-/home/erg/customrom/derp-17}"
CC="$(ls -d "$TOP"/prebuilts/clang/host/linux-x86/clang-r* | sort -V | tail -1)/bin/clang"
SR="$TOP/out/soong/ndk/sysroot"
PE="$TOP/prebuilts/extract-tools/linux-x86/bin/patchelf-0_18"
V=module/system/vendor/lib64
mkdir -p "$V"

shlib() { # <src> <soname> <out>
    "$CC" --target=aarch64-linux-android30 --sysroot="$SR" -fPIC -shared -O2 \
        -Wall -Werror -nostartfiles -nostdlib -L"$SR/usr/lib/aarch64-linux-android/30" -lc \
        -Wl,-soname,"$2" -Wl,-z,max-page-size=16384 -Wl,--build-id -o "$3" "$1"
}

# libmpbase: route malloc/realloc through the padding shim
shlib src/mpbase_shim.c libmpbase_shim.so "$V/libmpbase_shim.so"
cp "$TOP/vendor/xiaomi/raphael/proprietary/vendor/lib64/libmpbase.so" "$V/libmpbase.so"
printf 'malloc mpbase_shim_malloc\nrealloc mpbase_shim_realloc\n' > /tmp/mpbase_syms.$$
"$PE" --rename-dynamic-symbols /tmp/mpbase_syms.$$ "$V/libmpbase.so"
"$PE" --add-needed libmpbase_shim.so "$V/libmpbase.so"
rm -f /tmp/mpbase_syms.$$
