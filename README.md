# rtw89-macos-tun — RTL8852B Wi-Fi for macOS, no kernel extension (PKG installer)

TP-Link **Archer TX20U Nano**(Realtek **RTL8852B**、USB、Wi-Fi 6)を macOS で使うための、**カーネル拡張なし**のドライバです。
Linux 本家の `rtw89` を改変せずにユーザー空間で動かし、通信は **utun**(仮想ネットワークインターフェース)に流します。
メニューバーの**ランチャーアプリ**で接続を操作し、**PKG ファイル**でインストールできます。

> **Status: experimental.** 個人の実験プロジェクトです。無保証で、自己責任で使ってください。
> 「システム設定 > Wi-Fi」に出す版(カーネル拡張あり、Hackintosh 向け)は別リポジトリ [rtw89-macos](https://github.com/Long0823-1/rtw89-macos) です。

## インストール(PKG)
1. `dist/RTW89-WiFi-<version>.pkg`(下のビルド手順で作成)を開いて、案内に従います。署名していないため、初回は **右クリック > 開く**、または 「システム設定 > プライバシーとセキュリティ」で許可が必要です。
2. 子機を USB に挿します(最初は `0bda:1a2b` の「DISK」ですが、自動で Wi-Fi モードに切り替わります)。
3. メニューバーの「RTW89 Wi-Fi」からネットワークを選び、パスワードを入力します。次回以降は自動で接続します。

入るもの:
| 場所 | 内容 |
|---|---|
| `/usr/local/libexec/rtw89/rtw89d` | 常駐デーモン(LaunchDaemon `local.rtw89d`、root) |
| `/usr/local/share/rtw89/` | ファームウェア(Realtek、linux-firmware) |
| `/Applications/RTW89 Wi-Fi.app` | メニューバーのランチャー(LaunchAgent `local.rtw89.wifi` でログイン時に起動) |
| `/var/db/rtw89d/known.conf` | 接続したネットワーク(root のみ読める) |

ログ: `/var/log/rtw89d.log`。状態: `echo status | nc -U /var/run/rtw89d.sock`。
削除: `sudo /usr/local/libexec/rtw89/uninstall.sh`(保存したネットワークも消すなら `--purge`)。

## PKG のビルド
必要なもの: Xcode(フル版)、macOS 12 以降。
```bash
scripts/build-pkg.sh 0.1.0     # ファームウェア取得 → rtw89d と アプリをビルド → dist/RTW89-WiFi-0.1.0.pkg
```
署名とノータリゼーションが必要な場合は、`productsign` と `notarytool` で後から行ってください。

## 仕組み
```
メニューバーアプリ ── 制御ソケット(/var/run/rtw89d.sock) ──▶ rtw89d(root デーモン)
                                                          ├─ rtw89(Linux 本家、無改変)
                                                          ├─ kcompat + 簡易 mac80211 + MLME + WPA2/WPA3 supplicant
                                                          ├─ IOKit USB ── 子機
                                                          └─ utun + DHCP / ARP / IPv6 ND(デーモン内)
```
## 制限
* 「システム設定 > Wi-Fi」には出ません。macOS の Wi-Fi 設定の代わりに、メニューバーから操作します。
* WPA2-PSK、WPA3-SAE(ハンティング・アンド・ペッキング。H2E 必須の AP は未対応)。IPv6 は SLAAC のみ。
* 通常の Mac では、仮想 CD の切り替えが標準のストレージドライバに邪魔される場合があります。接続しないときは、挿し直してください。
* AirDrop は使えません。

## ライセンス
`rtw89` と Linux のヘッダーは GPL-2.0(rtw89 は GPL-2.0 OR BSD-3-Clause)。リンクした成果物は **GPL-2.0** です(`COPYING`、`THIRD_PARTY.md`)。
ファームウェアは Realtek のもので、リポジトリには含めず、`scripts/fetch-firmware.sh` で取得して PKG に同梱します。

## Support / 開発支援

開発・保守活動をKo-fiで支援できます。

[Ko-fiで支援する](https://ko-fi.com/long0823)
