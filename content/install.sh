#!/bin/sh

# Install AriaNg
wget -qO - https://github.com/mayswind/AriaNg/releases/download/1.2.4/AriaNg-1.2.4.zip | busybox unzip -qd /workdir/ariang -
sed -i 's|6800|443|g' /workdir/ariang/js/aria-ng-a87a79b0e7.min.js

# Install Rclone WebUI
wget -qO - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip | busybox unzip -qd /workdir/rcloneweb -

# Install Homer
wget -qO - https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip | busybox unzip -qd /workdir/homer -

# Install Filebrowser
wget -qO - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar -zxf - -C /usr/bin

# Install Rclone
DIR_TMP="$(mktemp -d)"
VERSION="$(curl --retry 5 https://api.github.com/repos/rclone/rclone/releases/latest | jq .tag_name | sed 's/\"//g')"
wget -qO - https://github.com/rclone/rclone/releases/download/${VERSION}/rclone-${VERSION}-linux-amd64.zip | busybox unzip -qd ${DIR_TMP} -
EXEC=$(head /dev/urandom |cksum |md5sum |cut -c 1-8)
mv ${DIR_TMP}/*/rclone /workdir/4${EXEC}
chmod +x /workdir/4${EXEC}
rm -rf ${DIR_TMP}

# Install Aria2
DIR_TMP="$(mktemp -d)"
wget -qO - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -zxf - -C ${DIR_TMP}
EXEC=$(head /dev/urandom |cksum |md5sum |cut -c 1-8)
mv ${DIR_TMP}/aria2c /workdir/2${EXEC}
rm -rf ${DIR_TMP}

# Install qBit
EXEC=$(head /dev/urandom |cksum |md5sum |cut -c 1-8)
wget -qO /workdir/1${EXEC} https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox
chmod +x /workdir/1${EXEC}

# Install OliveTin
DIR_TMP="$(mktemp -d)"
VERSION="$(curl --retry 5 https://api.github.com/repos/OliveTin/OliveTin/releases/latest | jq .tag_name | sed 's/\"//g')"
curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/download/${VERSION}/OliveTin-${VERSION}-Linux-amd64.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
mv ${DIR_TMP}/OliveTin-2022-04-07-linux-amd64/OliveTin /usr/bin/
mkdir -p /var/www/olivetin
mv ${DIR_TMP}/OliveTin-2022-04-07-linux-amd64/webui/* /var/www/olivetin/
rm -rf ${DIR_TMP}

# Install Vuetorrent
wget -qO - https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip | busybox unzip -qd /workdir -

# Install yt-dlp
wget -qO /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x /usr/bin/yt-dlp

# Install ffmpeg
wget -qO /usr/bin/ffmpeg https://github.com/eugeneware/ffmpeg-static/releases/latest/download/linux-x64
chmod +x /usr/bin/ffmpeg

chmod +x /workdir/aria2/*.sh
mv /workdir/ytdlp*.sh /usr/bin/
ln -s /workdir/service/* /etc/service/