#!/bin/sh

# Write dyno start time
echo $(date +%s) >/workdir/container_start_time

# Restore backup
RESTORE_BACKUP() {
    BACKUP=$(curl --retry 4 https://${CLOUDFLARE_WORKERS_HOST}/backup?key=${CLOUDFLARE_WORKERS_KEY} | jq .value | sed "s|\"||g")
    DIR_TMP="$(mktemp -d)"
    echo ${BACKUP} | base64 -d >${DIR_TMP}/backup.tar.gz
    tar -zxf ${DIR_TMP}/backup.tar.gz -C /mnt/data
    mv /mnt/data/config/settings /workdir/.pyload 2>/dev/null
    mv /mnt/data/config/gallery-dl /mnt/data/.cache 2>/dev/null
    mv /mnt/data/config/.config /mnt/data 2>/dev/null
    rm -rf ${DIR_TMP}
}

SEND_TG_MSG() {
    SCRIPT_CONF="/mnt/data/config/script.conf"
    TELEGRAM_BOT_TOKEN="$(grep ^telegram-bot-token "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TELEGRAM_CHAT_ID="$(grep ^telegram-chat-id "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TELEGRAM_TITLE="$(grep ^telegram-notification-title "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TG_PROXY="$(grep ^telegram-proxy "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    if [ "${TELEGRAM_CHAT_ID}" != "" ]; then
        if [ "${TG_PROXY}" != "" ]; then
            PROXY_PARAM="-x ${TG_PROXY}"
        fi
        if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
            msgbody="容器已启动"
        else
            msgbody="Container started"
        fi
        title="$TELEGRAM_TITLE"
        timestamp="$(date +"%m/%d %H:%M:%S")"
        msg="$title $timestamp\n$(echo "$msgbody" | sed -e 's|\\|\\\\|g' -e 's|\n|\\n|g' -e 's|\t|\\t|g' -e 's|\"|\\"|g')"
        entities="[{\"offset\":0,\"length\":${#title},\"type\":\"bold\"},{\"offset\":$((${#title} + 1)),\"length\":${#timestamp},\"type\":\"italic\"}]"
        data="{\"chat_id\":\"$TELEGRAM_CHAT_ID\",\"text\":\"$msg\",\"entities\":$entities,\"disable_notification\": true}"
        curl -s "${PROXY_PARAM}" -o /dev/null -H 'Content-Type: application/json' -X POST -d "$data" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
    fi
}

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /workdir/.pyload /mnt/data/.cache
WORKER_STATUS=$(curl -4 --retry 4 https://${CLOUDFLARE_WORKERS_HOST} | jq .status | sed "s|\"||g")

if [ "${WORKER_STATUS}" = "Running" ]; then
    RESTORE_BACKUP
else
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        echo "无法连接 Cloudflare Workers"
    else
        echo "Cloudflare Workers is not working"
    fi
    touch /workdir/workers_fail.lock
fi

if [ ! -f "/mnt/data/config/script.conf" ]; then
    cp /workdir/script.conf /mnt/data/config/script.conf
fi

SEND_TG_MSG

exec runsvdir /etc/service
