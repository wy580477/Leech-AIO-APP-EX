#!/bin/sh

DIR_TMP="$(mktemp -d)"

# Install AriaNg
wget -qO - https://github.com/mayswind/AriaNg/releases/download/1.3.2/AriaNg-1.3.2.zip | busybox unzip -qd /workdir/ariang -
sed -i 's|6800|443|g;s|protocol:"http"|protocol:"https"|g' /workdir/ariang/js/aria-ng-3fcc0271ed.min.js

# Install Rclone WebUI
wget -qO - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip | busybox unzip -qd /workdir/rcloneweb -

# Install Homer
wget -qO - https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip | busybox unzip -qd /workdir/homer -

# Install Filebrowser
wget -qO - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar -zxf - -C /usr/bin

# Install Rclone
wget -qO - https://downloads.rclone.org/rclone-current-linux-amd64.zip | busybox unzip -qd ${DIR_TMP} -
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
install -m 755 ${DIR_TMP}/*/rclone /workdir/4${EXEC}

# Install Aria2
wget -qO - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -zxf - -C ${DIR_TMP}
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
mv ${DIR_TMP}/aria2c /workdir/2${EXEC}

# Install qBit
wget -qO - https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-4.4.5.10/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip | busybox unzip -qd ${DIR_TMP} -
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
install -m 755 ${DIR_TMP}/qbittorrent-nox /workdir/1${EXEC}

# Install OliveTin
curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/latest/download/OliveTin-Linux-amd64.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
mv ${DIR_TMP}/*/OliveTin /usr/bin/
mkdir -p /var/www/olivetin
mv ${DIR_TMP}/*/webui/* /var/www/olivetin/

# Install Vuetorrent
wget -qO - https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip | busybox unzip -qd /workdir -

# Install yt-dlp
wget -qO /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x /usr/bin/yt-dlp

# Install ffmpeg
wget -qO /usr/bin/ffmpeg https://github.com/eugeneware/ffmpeg-static/releases/latest/download/linux-x64
chmod +x /usr/bin/ffmpeg

# Install pyload & gallery-dl & telegram-upload
apk add --no-cache --virtual .build-deps cargo curl-dev libffi-dev
pip install --no-cache-dir pyload-ng[plugins] --quiet >/dev/null
python3 -m pip install --no-cache-dir -U gallery-dl --quiet >/dev/null
pip install --no-cache-dir -U telegram-upload --quiet >/dev/null
apk del .build-deps
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
mv /usr/local/bin/pyload /usr/local/bin/1${EXEC}

rm -rf ${DIR_TMP}
chmod +x /workdir/aria2/*.sh
mv /workdir/ytdlp*.sh /usr/bin/
mkdir -p /workdir/.pyload/scripts/download_finished /workdir/.pyload/scripts/package_extracted
mv /workdir/pyload_to_rclone.sh /workdir/.pyload/scripts/download_finished/
mv /workdir/pyload_to_rclone_package_extracted.sh /workdir/.pyload/scripts/package_extracted/
ln -s /workdir/service/* /etc/service/
