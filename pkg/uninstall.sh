#!/bin/bash
# Removes the RTW89 Wi-Fi driver. Run with: sudo /usr/local/libexec/rtw89/uninstall.sh   (add --purge to also delete saved networks)
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
launchctl bootout system /Library/LaunchDaemons/local.rtw89d.plist 2>/dev/null
U=$(stat -f %Su /dev/console 2>/dev/null)
[ -n "$U" ] && [ "$U" != root ] && launchctl bootout "gui/$(id -u "$U")/local.rtw89.wifi" 2>/dev/null
pkill -x RTW89WiFi 2>/dev/null
rm -f /Library/LaunchDaemons/local.rtw89d.plist /Library/LaunchAgents/local.rtw89.wifi.plist
rm -rf "/Applications/RTW89 Wi-Fi.app" /usr/local/share/rtw89
[ "$1" = "--purge" ] && rm -rf /var/db/rtw89d
pkgutil --forget local.rtw89.wifi >/dev/null 2>&1
rm -rf /usr/local/libexec/rtw89
echo "removed"
