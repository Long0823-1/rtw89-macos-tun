#!/bin/bash
# Builds dist/RTW89-WiFi-<version>.pkg (unsigned). Usage: scripts/build-pkg.sh [version]
set -e
cd "$(dirname "$0")/.."
VER="${1:-0.1.0}"
scripts/fetch-firmware.sh
(cd port && mkdir -p build && make -j"$(sysctl -n hw.ncpu)")
mkdir -p app/RTW89WiFi.app/Contents/MacOS
swiftc -O app/Sources/main.swift -o app/RTW89WiFi.app/Contents/MacOS/RTW89WiFi -framework AppKit
codesign -s - --force app/RTW89WiFi.app >/dev/null 2>&1 || true

R=build/pkgroot
rm -rf build/pkgroot build/pkg dist; mkdir -p $R/usr/local/libexec/rtw89 $R/usr/local/share/rtw89 $R/Library/LaunchDaemons $R/Library/LaunchAgents $R/Applications build/pkg dist
install -m 755 port/rtw89d $R/usr/local/libexec/rtw89/rtw89d
install -m 755 pkg/uninstall.sh $R/usr/local/libexec/rtw89/uninstall.sh
for f in rtw8852b_fw-2.bin rtw8852b_fw-1.bin rtw8852b_fw.bin; do [ -f rtw89/$f ] && install -m 644 rtw89/$f $R/usr/local/share/rtw89/; done
install -m 644 pkg/local.rtw89d.plist $R/Library/LaunchDaemons/
install -m 644 pkg/local.rtw89.wifi.plist $R/Library/LaunchAgents/
ditto app/RTW89WiFi.app "$R/Applications/RTW89 Wi-Fi.app"

chmod 755 pkg/scripts/preinstall pkg/scripts/postinstall
pkgbuild --analyze --root $R build/pkg/components.plist >/dev/null
plutil -replace 0.BundleIsRelocatable -bool NO build/pkg/components.plist 2>/dev/null || true
pkgbuild --root $R --component-plist build/pkg/components.plist --identifier local.rtw89.wifi --version "$VER" --install-location / --scripts pkg/scripts build/pkg/rtw89.pkg
sed "s/VERSION/$VER/" pkg/distribution.xml > build/pkg/distribution.xml
productbuild --distribution build/pkg/distribution.xml --resources pkg/resources --package-path build/pkg "dist/RTW89-WiFi-$VER.pkg"
echo "built dist/RTW89-WiFi-$VER.pkg"
