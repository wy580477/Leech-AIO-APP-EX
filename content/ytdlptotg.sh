#!/bin/bash

touch /mnt/data/log/ytdlp.log

exec &> >(tee -a /mnt/data/log/ytdlp.log)

yt-dlp --exec ytdlpuptg.sh -P /mnt/data/videos --no-progress "$@"