#!/bin/sh

# Write dyno start time
echo $(date +%s) > /workdir/dyno_start_time

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /workdir/.pyload /mnt/data/.cache

# Restore backup
BACKUP=$(curl --retry 4 https://${CLOUDFLARE_WORKERS_HOST}/backup?key=${CLOUDFLARE_WORKERS_KEY} | jq .value)
DIR_TMP="$(mktemp -d)"
echo ${BACKUP} | base64 -d >${DIR_TMP}/backup.tar.gz
tar -zxf ${DIR_TMP}/backup.tar.gz -C /mnt/data
mv /mnt/data/config/settings /workdir/.pyload 2>/dev/null
mv /mnt/data/config/gallery-dl /mnt/data/.cache 2>/dev/null
mv /mnt/data/config/.config /mnt/data 2>/dev/null
rm -rf ${DIR_TMP}

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

exec runsvdir -P /etc/service
