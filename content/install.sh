#!/bin/bash

ARIANG_VERSION="1.3.6"
RCLONEWEB_VERSION="2.0.5"
QBIT_VERSION="4.5.5.10"

DIR_TMP="$(mktemp -d)"
source /etc/env
export $(sed '/^#/d' /etc/env | cut -d= -f1)

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "安装将用时一分钟左右"
else
    echo "Install process will take about one minute"
fi

INSTALL_JQ_RUNIT() {
    rm -rf /etc/apt/sources.list.d
    CODE_NAME=$(lsb_release -c | sed 's/.*:\s*//')
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${CODE_NAME} main universe" >/etc/apt/sources.list
    apt-get -qq update >/dev/null && apt-get -qq install -y fuse3 jq runit >/dev/null
}

INSTALL_PYLOAD() {
    if [ "${PYLOAD_INSTALL}" = "Enable" ]; then
        pip install --no-cache-dir pyload-ng[plugins] --quiet >/dev/null
        EXEC=$(echo $RANDOM | md5sum | head -c 6)
        mv /usr/local/bin/pyload /usr/local/bin/1${EXEC}
        mkdir -p /mnt/data/pyload_downloads /workdir/.pyload/scripts/download_finished /workdir/.pyload/scripts/package_extracted
        mv /workdir/pyload_to_rclone.sh /workdir/.pyload/scripts/download_finished/
        mv /workdir/pyload_to_rclone_package_extracted.sh /workdir/.pyload/scripts/package_extracted/
    else
        rm -rf /workdir/service/6 /workdir/pyload*
    fi
}

INSTALL_GALLERY_DL() {
    python3 -m pip install --no-cache-dir -U gallery-dl --quiet >/dev/null
    if [ ! -f "/mnt/data/config/gallery-dl.conf" ]; then
        cp /workdir/gallery-dl.conf /mnt/data/config/gallery-dl.conf
    fi
}

INSTALL_OLIVETIN() {
    curl -s --retry 5 -H "Cache-Control: no-cache" -fsSL github.com/OliveTin/OliveTin/releases/latest/download/OliveTin-Linux-amd64.tar.gz -o - | tar -zxf - -C ${DIR_TMP}
    mv ${DIR_TMP}/*/OliveTin /usr/bin/
    mkdir -p /var/www/olivetin
    mv ${DIR_TMP}/*/webui/* /var/www/olivetin/
}

INSTALL_TTYD() {
    wget -qO /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
    chmod +x /usr/bin/ttyd
}

INSTALL_CADDY() {
    RELEASE_LATEST="$(wget -S -O /dev/null https://github.com/caddyserver/caddy/releases/latest 2>&1 | grep -o 'v[0-9]*\..*' | tail -1)"
    wget -qO - "https://github.com/caddyserver/caddy/releases/download/${RELEASE_LATEST}/caddy_${RELEASE_LATEST#v}_linux_amd64.tar.gz" | tar -zxf - -C ${DIR_TMP}
    install -m 755 ${DIR_TMP}/caddy /usr/bin/caddy
}

INSTALL_ARIANG() {
    wget -qP ${DIR_TMP} https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip
    unzip -qd /workdir/ariang ${DIR_TMP}/AriaNg-${ARIANG_VERSION}.zip
    sed -i 's|6800|443|g;s|protocol:"http"|protocol:"https"|g' /workdir/ariang/js/aria-ng*.min.js
}

INSTALL_RCLONE_WEBUI() {
    wget -qP ${DIR_TMP} - https://github.com/rclone/rclone-webui-react/releases/download/v${RCLONEWEB_VERSION}/currentbuild.zip
    unzip -qd /workdir/rcloneweb ${DIR_TMP}/currentbuild.zip
}

INSTALL_HOMER() {
    wget -qP ${DIR_TMP} https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
    unzip -qd /workdir/homer ${DIR_TMP}/homer.zip
}

INSTALL_FILEBROWSER() {
    wget -qO - https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz | tar -zxf - -C /usr/bin
}

INSTALL_RCLONE() {
    wget -qP ${DIR_TMP} https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip -qd ${DIR_TMP} ${DIR_TMP}/rclone-current-linux-amd64.zip
    EXEC=$(echo $RANDOM | md5sum | head -c 6)
    install -m 755 ${DIR_TMP}/*/rclone /workdir/4${EXEC}
}

INSTALL_ARIA2() {
    wget -qO - https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -zxf - -C ${DIR_TMP}
    EXEC=$(echo $RANDOM | md5sum | head -c 6)
    mv ${DIR_TMP}/aria2c /workdir/2${EXEC}
}

INSTALL_QBITTORRENT() {
    wget -qP ${DIR_TMP} https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${QBIT_VERSION}/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
    unzip ${DIR_TMP}/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
    EXEC=$(echo $RANDOM | md5sum | head -c 6)
    install -m 755 ./qbittorrent-nox /workdir/1${EXEC}
}

INSTALL_VUETORRENT() {
    wget -qP ${DIR_TMP} https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip
    unzip -qd /workdir ${DIR_TMP}/vuetorrent.zip
}

INSTALL_YTDLP() {
    wget -qO /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
    chmod +x /usr/bin/yt-dlp
}

INSTALL_FFMPEG() {
    wget -qO - https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz | tar -xJf - -C ${DIR_TMP}
    install -m 755 ${DIR_TMP}/ffmpeg*/bin/ffmpeg /usr/bin/ffmpeg
    install -m 755 ${DIR_TMP}/ffmpeg*/bin/ffprobe /usr/bin/ffprobe
}

INSTALL_CLOUDFLARED() {
    wget -qO /usr/bin/argo https://github.com/cloudflare/cloudflared/releases/download/2023.4.2/cloudflared-fips-linux-amd64
    chmod +x /usr/bin/argo
}

OTHER_TASKS() {
    # Configure scripts
    chmod +x /workdir/*.sh /workdir/aria2/*.sh /workdir/service/*/run /workdir/service/*/log/run
    sed -i 's/\r$//' /workdir/*.sh /workdir/aria2/*.sh /workdir/aria2/core /workdir/service/*/run /workdir/service/*/log/run /workdir/rclone_options.conf /workdir/bashrc
    mv /workdir/ytdlp*.sh /usr/bin/
    mkdir -p /mnt/data/.cache /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /mnt/data/gallery_dl_downloads
    PORTAL_PATH=$(echo ${RANDOM} | md5sum | head -c 6)
    echo GLOBAL_PORTAL_PATH=/${PORTAL_PATH} >>/etc/env

    # restore backup
    tar -zxf /content/drive/*/AIO_FILES/backup.tar.gz -C /mnt/data 2>/dev/null
    mv /mnt/data/config/settings /workdir/.pyload 2>/dev/null
    mv /mnt/data/config/gallery-dl /mnt/data/.cache 2>/dev/null

    if [ ! -f "/mnt/data/config/script.conf" ]; then
        cp /workdir/script.conf /mnt/data/config/script.conf
    fi

    sed -i 's/\r$//' /mnt/data/config/script.conf
}

OTHER_TASKS
INSTALL_JQ_RUNIT &
INSTALL_PYLOAD &
INSTALL_GALLERY_DL &
INSTALL_OLIVETIN &
INSTALL_TTYD &
INSTALL_CADDY &
INSTALL_ARIANG &
INSTALL_RCLONE_WEBUI &
INSTALL_HOMER &
INSTALL_FILEBROWSER &
INSTALL_RCLONE &
INSTALL_ARIA2 &
INSTALL_QBITTORRENT &
INSTALL_VUETORRENT &
INSTALL_YTDLP &
INSTALL_FFMPEG &
INSTALL_CLOUDFLARED &

wait
rm -rf ${DIR_TMP}

# Run services
ln -s /workdir/service/* /etc/service
nohup runsvdir /etc/service &

# Run cloudflared
bash /workdir/cloudflared.sh