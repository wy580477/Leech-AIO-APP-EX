#!/bin/sh

mkdir -p /mnt/data/config /mnt/data/qbit_downloads /mnt/data/aria2_downloads /mnt/data/videos /mnt/data/gallery_dl_downloads 2>/dev/null

if [ ! -f "/mnt/data/config/script.conf" ]; then
       cp /workdir/script.conf /mnt/data/config/script.conf
fi

if [ ! -f "/mnt/data/config/gallery-dl.conf" ]; then
       cp /workdir/gallery-dl.conf /mnt/data/config/gallery-dl.conf
fi

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

SEND_TG_MSG

if [ "${OLIVETIN}" != "Enable" ]; then
       rm -rf /etc/service/olivetin
fi

exec runsvdir -P /etc/service
