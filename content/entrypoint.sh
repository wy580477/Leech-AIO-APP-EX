#!/bin/sh

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /mnt/data/gallery_dl_downloads 2>/dev/null

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

if [ ! -f "/mnt/data/config/gallery-dl.conf" ]; then
       cp /workdir/gallery-dl.conf /mnt/data/config/gallery-dl.conf
fi

if [ "${OLIVETIN}" != "Enable" ]; then
       rm -rf /etc/service/olivetin
fi

exec runsvdir -P /etc/service
