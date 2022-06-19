#!/bin/bash

source /etc/env
export $(sed '/^#/d' /etc/env | cut -d= -f1)

if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
    echo "Cloudflared Argo 隧道将于 10 秒至 1 分钟后准备好"
else
    echo "Cloudflared Argo Tunnel will be ready in one minute"
fi

killall argo 2>/dev/null
rm -f nohup.out
nohup argo tunnel --url http://localhost:8880 &
sleep 5

while [[ "${URL}" = "" ]]; do
    URL=$(grep -oP "https://.*trycloudflare.com" nohup.out)
    sleep 3
done

while [[ "${HTTP_CODE}" -ne 200 ]]; do
    HTTP_CODE=$(curl -I -s -w %{http_code} ${URL} -o /dev/null)
    sleep 5
done

echo ${URL}${GLOBAL_PORTAL_PATH}
tail -f
