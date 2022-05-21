#!/bin/sh

touch /mnt/data/log/ytdlp.log

exec &> >(tee -a /mnt/data/log/ytdlp.log)

yt-dlp --exec ytdlptorclone.sh -P /mnt/data/videos --no-progress "$@"