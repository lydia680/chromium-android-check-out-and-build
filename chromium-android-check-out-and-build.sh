#!/bin/bash
set -e
#system information
lscpu
CORES=$(nproc)
echo "Cores: $CORES"
df -h

do_job()
{
# By removing [cd "$HOME"] this script works in any path/location on your machine.
#cd "$HOME"

CURRENT_DIR=$(pwd)

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$CURRENT_DIR/depot_tools"
mkdir -p "$CURRENT_DIR/chromium" && cd "$CURRENT_DIR/chromium"
fetch --nohooks --no-history android
cd src
gclient sync
build/install-build-deps-android.sh
gclient runhooks

OUT_DIR="out"

#target_cpu: can be arm, arm64, x86 or x64.
OUT_ARCH="arm64"
ARGS_FILE="args.gn"

# change the arguments for your needs.
ARGS_FILE_CONTENT='target_os="android"
target_cpu="'"$OUT_ARCH"'"
is_debug=false
is_official_build=true
enable_remoting=true
is_component_build=false
is_chrome_branded=false
use_official_google_api_keys=false
enable_resource_whitelist_generation=true
enable_nacl=false
remove_webcore_debug_symbols=true
proprietary_codecs=true
ffmpeg_branding="Chrome"
android_channel="stable"'
mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/$OUT_ARCH"
printf '%s\n' "$ARGS_FILE_CONTENT"  > "$OUT_DIR/$OUT_ARCH/$ARGS_FILE"


gn gen $OUT_DIR/$OUT_ARCH

# Exit here, because travis ci force a timeout after 50 mins for this job.
# Remove this exit on your machine and everything will be fine
exit 0
autoninja -C $OUT_DIR/$OUT_ARCH chrome_public_apk

echo "Done!"
}
do_job
