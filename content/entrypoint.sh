#!/bin/sh

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos
BACKUP=$(curl --retry 4 https://${CLOUDFLARE_WORKERS_HOST}/backup?key=${CLOUDFLARE_WORKERS_KEY} | jq .value)
DIR_TMP="$(mktemp -d)"
echo ${BACKUP} | base64 -d >${DIR_TMP}/backup.tar.gz
tar -zxf ${DIR_TMP}/backup.tar.gz -C /mnt/data
rm -rf ${DIR_TMP}

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

exec runsvdir -P /etc/service
