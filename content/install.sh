#!/bin/sh

set -xe

DIR_TMP="$(mktemp -d)"
QBIT_VERSION="4.5.5.10"

OS_type="$(uname -m)"
case "$OS_type" in
x86_64 | amd64)
  OS_type='amd64'
  OS_type2='x86_64-linux-musl_static'
  OS_type3='amd64'
  OS_type4='amd64'
  OS_type5='amd64'
  OS_type6='amd64'
  ;;
aarch64 | arm64)
  OS_type='arm64'
  OS_type2='aarch64-linux-musl_static'
  OS_type3='arm64'
  OS_type4='arm64'
  OS_type5='arm64'
  OS_type6='arm64'
  ;;
arm*)
  OS_type='arm-v7'
  OS_type2='arm-linux-musleabi_static'
  OS_type3='armv7'
  OS_type4='armhf'
  OS_type5='arm32v7'
  OS_type6='arm&arm=7'
  ;;
*)
  echo 'OS type not supported'
  exit 2
  ;;
esac

# Install Rclone
wget -O - https://downloads.rclone.org/rclone-current-linux-${OS_type}.zip | busybox unzip -qd ${DIR_TMP} -
install -m 755 ${DIR_TMP}/*/rclone /usr/bin/rclone

# Install qBit
wget -O - https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${QBIT_VERSION}/qbittorrent-enhanced-nox_${OS_type2}.zip | busybox unzip -qd ${DIR_TMP} -
install -m 755 ${DIR_TMP}/qbittorrent-nox /usr/bin/qbittorrent-nox

# Install Filebrowser
wget -O - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-${OS_type3}-filebrowser.tar.gz | tar -zxf - -C /usr/bin

# Install Aria2
wget -O - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-${OS_type4}.tar.gz | tar -zxf - -C /usr/bin

# Install OliveTin
curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/latest/download/OliveTin-Linux-${OS_type5}.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
mv ${DIR_TMP}/*/OliveTin /usr/bin/
mkdir -p /var/www/olivetin
mv ${DIR_TMP}/*/webui/* /var/www/olivetin/

rm -rf ${DIR_TMP}
