#!/bin/sh

source /workdir/script_core.sh
TELEGRAM_DEST="$(grep ^telegram-dest "${SCRIPT_CONF}" | cut -d= -f2-)"

SEND_TO_TG() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG yt-dlp "$1 下载已完成并发送上传任务至 Telegram"
    else
        SEND_TG_MSG yt-dlp "$1 download completed and send upload job to Telegram"
    fi
}

if [ "${TELEGRAM_DEST}" != "" ]; then
    DEST_PARAM="--to ${TELEGRAM_DEST}"
fi

SEND_TO_TG
telegram-upload ${DEST_PARAM} -d "$1"
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
    echo "[INFO] Successfully upload file to Telegram: $1"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG Telegram "[INFO] Telegram 上传任务已成功: $1"
    else
        SEND_TG_MSG Telegram "[INFO] File successfully uploaded to Telegram : $1"
    fi
else
    echo "[ERROR] Failed to upload file to Telegram: $1"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG Telegram "[ERROR] Telegram 上传任务失败: $1"
    else
        SEND_TG_MSG Telegram "[ERROR] Failed to upload file to Telegram: $1"
    fi
fi 