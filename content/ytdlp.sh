#!/bin/sh

touch /mnt/data/log/ytdlp.log

exec &> >(tee -a /mnt/data/log/ytdlp.log)

yt-dlp -P /mnt/data/videos --no-progress "$@"