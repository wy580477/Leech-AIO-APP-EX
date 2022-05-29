#!/bin/sh

source /etc/env
export $(sed '/^#/d' /etc/env | cut -d= -f1)

killall argo 2>/dev/null
rm -f nohup.out
nohup argo tunnel --url http://localhost:8880 &
sleep 5

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "Cloudflared Argo 隧道将于 10 秒至 1 分钟后准备好"
else
    echo "Cloudflared Argo Tunnel will be ready in one minute"
fi

echo $(grep -oP "https://.*trycloudflare.com" nohup.out)${GLOBAL_PORTAL_PATH}
