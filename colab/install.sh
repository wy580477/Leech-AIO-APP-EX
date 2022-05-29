#!/bin/bash

DIR_TMP="$(mktemp -d)"
source /etc/env
export $(sed '/^#/d' /etc/env | cut -d= -f1)

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "安装将用时一到两分钟"
else
    echo "Install process will take 1-2 minutes"
fi

# Install jq & runit
echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" >>/etc/apt/sources.list
apt-get -qq update >/dev/null && apt-get -qq install -y jq runit >/dev/null
rm -rf /var/lib/apt/lists/*

# Install pyload
pip install --no-cache-dir --pre pyload-ng[plugins] --quiet 2>&1 >/dev/null
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
mv /usr/local/bin/pyload /usr/local/bin/1${EXEC}

# Install OliveTin
VERSION="$(curl --retry 5 https://api.github.com/repos/OliveTin/OliveTin/releases/latest | jq .tag_name | sed 's/\"//g')"
curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/download/${VERSION}/OliveTin-${VERSION}-Linux-amd64.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
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
wget -qP ${DIR_TMP} https://github.com/mayswind/AriaNg/releases/download/1.2.4/AriaNg-1.2.4.zip
unzip -qd /workdir/ariang ${DIR_TMP}/AriaNg-1.2.4.zip
sed -i 's|6800|443|g' /workdir/ariang/js/aria-ng-a87a79b0e7.min.js

# Install Rclone WebUI
wget -qP ${DIR_TMP} - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip
unzip -qd /workdir/rcloneweb ${DIR_TMP}/currentbuild.zip

# Install Homer
wget -qP ${DIR_TMP} https://github.com/wy580477/homer/releases/latest/download/homer.zip
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
EXEC=$(echo $RANDOM | md5sum | head -c 6; echo)
wget -qO  /workdir/1${EXEC} https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox
chmod +x /workdir/1${EXEC}

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


rm -rf ${DIR_TMP} /workdir/service/3 /workdir/service/5
sed -i "s/message\:/#&/;s/Heroku/Colab/g" /workdir/homer_conf/homer_*.yml

# Configure scripts
chmod +x /workdir/aria2/*.sh /workdir/service/*/run /workdir/service/*/log/run
sed -i 's/\r$//' /workdir/*.sh /workdir/aria2/*.sh /workdir/aria2/core /workdir/service/*/run /workdir/service/*/log/run /workdir/rclone_options.conf /workdir/bashrc
sed -i 's|bin/sh|bin/bash|g' /workdir/*.sh /workdir/aria2/*.sh /workdir/service/*/run /workdir/service/*/log/run
mv /workdir/ytdlp*.sh /usr/bin/
mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /workdir/.pyload/scripts/download_finished /workdir/.pyload/scripts/package_extracted
mv /workdir/pyload_to_rclone.sh /workdir/.pyload/scripts/download_finished/
mv /workdir/pyload_to_rclone_package_extracted.sh /workdir/.pyload/scripts/package_extracted/

# restore backup
tar -zxf /content/drive/*/AIO_FILES/backup.tar.gz -C /mnt/data 2>/dev/null
mv /mnt/data/config/settings /workdir/.pyload 2>/dev/null

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
