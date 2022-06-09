#!/bin/sh

DIR_TMP="$(mktemp -d)"

OS_type="$(uname -m)"
case "$OS_type" in
  x86_64|amd64)
    OS_type='amd64'
    OS_type2='x86_64'
    OS_type3='amd64'
    OS_type4='amd64'
    ;;
  aarch64|arm64)
    OS_type='arm64'
    OS_type2='aarch64'
    OS_type3='arm64'
    OS_type3='arm64'
    ;;
  arm*)
    OS_type='arm-v7'
    OS_type2='armv7'
    OS_type3='armv7'
    OS_type4='armhf'
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
wget -O /usr/bin/qbit https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/${OS_type2}-qbittorrent-nox
chmod +x /usr/bin/qbit

# Install Filebrowser
wget -O - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-${OS_type3}-filebrowser.tar.gz | tar -zxf - -C /usr/bin

# Install Aria2
wget -O - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -zxf - -C /usr/bin

rm -rf ${DIR_TMP}