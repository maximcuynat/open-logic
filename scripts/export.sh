#!/usr/bin/env bash
# Exports every preset of export_presets.cfg and packages them as zips with
# SHA256 checksums in build/release/. Usage: scripts/export.sh [version]
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

version="${1:-$(project_version)}"

templates="$(export_templates_dir)"
for t in macos.zip windows_release_x86_64.exe linux_release.x86_64 web_nothreads_release.zip; do
  [[ -f "$templates/$t" ]] || die "missing export template $templates/$t
       Install them from the Godot editor: Editor > Manage Export Templates > Download and Install"
done
out="build/release"
rm -rf build/export "$out"
mkdir -p build/export/{macos,windows,linux,web} "$out"

export_preset() { # preset name, output path
  info "Exporting $1"
  "$GODOT" --headless --path . --export-release "$1" "$2" 2>&1 | grep -Ev '^\s*$' | tail -5
  [[ -e "$2" ]] || die "export of '$1' produced nothing (are export templates installed? run make doctor)"
}

export_preset "macOS"   "build/export/macos/$APP_NAME.zip"
export_preset "Windows" "build/export/windows/$APP_NAME.exe"
export_preset "Linux"   "build/export/linux/$APP_NAME.x86_64"
export_preset "Web"     "build/export/web/index.html"

info "Packaging v$version"
cp "build/export/macos/$APP_NAME.zip" "$out/$APP_NAME-v$version-macos.zip"
for platform in windows linux web; do
  (cd "build/export/$platform" && zip -qr "$ROOT_DIR/$out/$APP_NAME-v$version-$platform.zip" .)
done
(cd "$out" && shasum -a 256 ./*.zip | sed 's# \./# #' > SHA256SUMS)
cat "$out/SHA256SUMS"
info "Artifacts ready in $out/"
