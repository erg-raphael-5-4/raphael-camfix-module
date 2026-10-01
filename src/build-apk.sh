#!/bin/bash
# Patch the Leica port MiuiCamera.apk: decode the dex (no resources), apply
# src/apk/patches, reassemble only the touched dex files, put them back into
# a copy of the original APK, zipalign and sign it with the platform key.
#   TOP=<derp-17 tree> CERTS=<key dir> src/build-apk.sh
set -e
cd "$(dirname "$0")/.."
TOP="${TOP:-/home/erg/customrom/derp-17}"
CERTS="${CERTS:-$HOME/.android-certs}"
IN="${IN:-$TOP/vendor/xiaomi/miuicamera/proprietary/system/priv-app/MiuiCamera/MiuiCamera.apk}"
OUT=module/system/priv-app/MiuiCamera/MiuiCamera.apk
APKTOOL="$TOP/prebuilts/extract-tools/common/apktool/apktool.jar"
SMALI="$TOP/prebuilts/extract-tools/common/smali/smali.jar"
BIN="$TOP/out/host/linux-x86/bin"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

head -c 100 "$IN" | grep -q "git-lfs" && { echo "$IN is an LFS pointer" >&2; exit 1; }
java -jar "$APKTOOL" d -r -f -o "$WORK/dec" "$IN" >/dev/null

dirs=""
for p in src/apk/patches/*.patch; do
    patch -d "$WORK/dec" -p1 --no-backup-if-mismatch -s < "$p"
    for f in $(sed -n 's#^+++ b/\([^ \t]*\).*#\1#p' "$p"); do
        d="${f%%/*}"
        case " $dirs " in *" $d "*) ;; *) dirs="$dirs $d" ;; esac
    done
done

mkdir -p "$WORK/dex"
for d in $dirs; do
    if [ "$d" = smali ]; then dex=classes.dex; else dex=classes${d#smali_classes}.dex; fi
    ver=$(unzip -p "$IN" "$dex" | head -c 7 | tail -c 3)
    case "$ver" in 035) api=23 ;; 037) api=25 ;; 038) api=26 ;; *) api=28 ;; esac
    java -jar "$SMALI" a -a "$api" -o "$WORK/dex/$dex" "$WORK/dec/$d"
done

cp "$IN" "$WORK/unaligned.apk"
(cd "$WORK/dex" && zip -q -d "$WORK/unaligned.apk" *.dex && zip -q -X -9 "$WORK/unaligned.apk" *.dex)
mkdir -p "$(dirname "$OUT")"
"$BIN/zipalign" -f -P 16 4 "$WORK/unaligned.apk" "$WORK/aligned.apk"
"$BIN/apksigner" sign --key "$CERTS/platform.pk8" --cert "$CERTS/platform.x509.pem" \
    --out "$OUT" "$WORK/aligned.apk"
rm -f "$OUT.idsig"
"$BIN/apksigner" verify "$OUT"
echo "$OUT ($(echo $dirs))"
