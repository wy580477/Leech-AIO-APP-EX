#!/bin/sh

# Write container start time
echo $(date +%s) > /workdir/container_start_time

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

exec runsvdir -P /etc/service
