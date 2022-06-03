#!/bin/sh

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos 2>/dev/null

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

if [ "${VmessUUID}" = "" ]; then
       rm -rf /etc/service/xray
       sed -i "s|Vmess UUID: VmessUUID<br />Vmess Websocket Path: GLOBAL_PORTAL_PATH/vm<br />||g" /workdir/homer_conf/*.yml
fi

exec runsvdir -P /etc/service
