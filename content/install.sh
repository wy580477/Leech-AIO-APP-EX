#!/bin/bash

DIR_TMP="$(mktemp -d)"
source /etc/env
export $(sed '/^#/d' /etc/env | cut -d= -f1)

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "安装将用时一到两分钟"
else
    echo "Install process will take 1-2 minutes"
fi

# Configure scripts
chmod +x /workdir/*.sh /workdir/aria2/*.sh /workdir/service/*/run /workdir/service/*/log/run
sed -i 's/\r$//' /workdir/*.sh /workdir/aria2/*.sh /workdir/aria2/core /workdir/service/*/run /workdir/service/*/log/run /workdir/rclone_options.conf /workdir/bashrc
mv /workdir/ytdlp*.sh /usr/bin/
mkdir -p /mnt/data/.cache /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /mnt/data/gallery_dl_downloads

# Install jq & runit
rm -rf /etc/apt/sources.list.d
CODE_NAME=$(lsb_release -c | sed 's/.*:\s*//')
echo "deb http://us.archive.ubuntu.com/ubuntu/ ${CODE_NAME} main universe" >/etc/apt/sources.list
apt-get -qq update >/dev/null && apt-get -qq install -y jq runit >/dev/null

# Install pyload
if [ "${PYLOAD_INSTALL}" = "Enable" ]; then
    pip install --no-cache-dir pyload-ng[plugins] --quiet >/dev/null
    EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
    mv /usr/local/bin/pyload /usr/local/bin/1${EXEC}
    mkdir -p /mnt/data/pyload_downloads /workdir/.pyload/scripts/download_finished /workdir/.pyload/scripts/package_extracted
    mv /workdir/pyload_to_rclone.sh /workdir/.pyload/scripts/download_finished/
    mv /workdir/pyload_to_rclone_package_extracted.sh /workdir/.pyload/scripts/package_extracted/
else
    rm -rf /workdir/service/6 /workdir/pyload*
fi
    
# Install gallery-dl
python3 -m pip install --no-cache-dir -U gallery-dl --quiet >/dev/null

if [ ! -f "/mnt/data/config/gallery-dl.conf" ]; then
    cp /workdir/gallery-dl.conf /mnt/data/config/gallery-dl.conf
fi

# Install OliveTin
curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/latest/download/OliveTin-Linux-amd64.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
mv ${DIR_TMP}/*/OliveTin /usr/bin/
mkdir -p /var/www/olivetin
mv ${DIR_TMP}/*/webui/* /var/www/olivetin/

# Install ttyd
wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
chmod +x /usr/bin/ttyd

# Install Caddy
wget -qO /usr/bin/caddy "https://caddyserver.com/api/download?os=linux&arch=amd64"
chmod +x /usr/bin/caddy

# Install AriaNg
wget -qP ${DIR_TMP} https://github.com/mayswind/AriaNg/releases/download/1.3.2/AriaNg-1.3.2.zip
unzip -qd /workdir/ariang ${DIR_TMP}/AriaNg-1.3.2.zip
sed -i 's|6800|443|g;s|protocol:"http"|protocol:"https"|g' /workdir/ariang/js/aria-ng-3fcc0271ed.min.js

# Install Rclone WebUI
wget -qP ${DIR_TMP} - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip
unzip -qd /workdir/rcloneweb ${DIR_TMP}/currentbuild.zip

# Install Homer
wget -qP ${DIR_TMP} https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
unzip -qd /workdir/homer ${DIR_TMP}/homer.zip

# Install Filebrowser
wget -qO - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar -zxf - -C /usr/bin

# Install Rclone
wget -qP ${DIR_TMP} https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip -qd ${DIR_TMP} ${DIR_TMP}/rclone-current-linux-amd64.zip
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
install -m 755 ${DIR_TMP}/*/rclone /workdir/4${EXEC}

# Install Aria2
wget -qO - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -zxf - -C ${DIR_TMP}
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
mv ${DIR_TMP}/aria2c /workdir/2${EXEC}

# Install qBit
wget -qP ${DIR_TMP} https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-4.4.5.10/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
unzip ${DIR_TMP}/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
install -m 755 ./qbittorrent-nox /workdir/1${EXEC}

# Install Vuetorrent
wget -qP ${DIR_TMP} https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip
unzip -qd /workdir ${DIR_TMP}/vuetorrent.zip

# Install yt-dlp
wget -qO /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x /usr/bin/yt-dlp

# Install ffmpeg
wget -qO /usr/bin/ffmpeg https://github.com/eugeneware/ffmpeg-static/releases/latest/download/linux-x64
chmod +x /usr/bin/ffmpeg

# Install Cloudflared
wget -qO /usr/bin/argo https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/bin/argo


rm -rf ${DIR_TMP}
PORTAL_PATH=$(echo ${RANDOM} | md5sum | head -c 6; echo)
echo GLOBAL_PORTAL_PATH=/${PORTAL_PATH} >>/etc/env

# restore backup
tar -zxf /content/drive/*/AIO_FILES/backup.tar.gz -C /mnt/data 2>/dev/null
mv /mnt/data/config/settings /workdir/.pyload 2>/dev/null
mv /mnt/data/config/gallery-dl /mnt/data/.cache 2>/dev/null

if [ ! -f "/mnt/data/config/script.conf" ]; then
    cp /workdir/script.conf /mnt/data/config/script.conf
fi

sed -i 's/\r$//' /mnt/data/config/script.conf

# Run services
ln -s /workdir/service/* /etc/service
nohup runsvdir -P /etc/service &

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "<<安装已完成, 运行下一单元格启动 Cloudflare Argo 隧道。>>"
else
    echo "<<Install completed, run next Cell to start Cloudflare Argo Tunnel.>>"
fi
