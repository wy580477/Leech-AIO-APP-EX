#!/bin/bash

source /workdir/script_core.sh
FILE_NAME="$(basename "$1")"

SEND_TO_TG() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG yt-dlp "${FILE_NAME} 下载已完成并发送上传任务至 Telegram"
    else
        SEND_TG_MSG yt-dlp "${FILE_NAME} download completed and send upload job to Telegram"
    fi
}

GET_PATH
if [ "${TG_PROXY}" != "" ]; then
    PROXY_PARAM="-p ${TG_PROXY}"
fi
TELEGRAM_DEST="$(grep ^telegram-dest ${SCRIPT_CONF} | cut -d= -f2-)"
TELEGRAM_MODE="$(grep ^telegram-auto-upload-mode ${SCRIPT_CONF} | cut -d= -f2-)"
if [ "${TELEGRAM_DEST}" != "" ]; then
    DEST_PARAM="--to ${TELEGRAM_DEST}"
fi
if [ "${TELEGRAM_MODE}" = "move" ]; then
    UP_MODE_PARAM="-d"
fi
SEND_TO_TG
RETRY=0
RETRY_NUM=10
while [ ${RETRY} -le ${RETRY_NUM} ]; do
    [ ${RETRY} != 0 ] && (
        echo -e "$(DATE_TIME) ${ERROR} Telegram Upload failed! Retry ${RETRY}/${RETRY_NUM} ..."
    )
    telegram-upload ${DEST_PARAM} ${PROXY_PARAM} ${UP_MODE_PARAM} "$1"
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -eq 0 ]; then
        echo "$(DATE_TIME) [INFO] Successfully upload file to Telegram: $1"
        if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
            SEND_TG_MSG Telegram "[INFO] Telegram 上传任务已成功: $1"
        else
            SEND_TG_MSG Telegram "[INFO] File successfully uploaded to Telegram : $1"
        fi
        break
    else
        RETRY=$((${RETRY} + 1))
        sleep 10
    fi
done
if [[ "${RETRY}" -eq 2 ]] && [[ ! "${EXIT_CODE}" -eq 0 ]]; then
    echo "$(DATE_TIME) [ERROR] Failed to upload file to Telegram: $1"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG Telegram "[ERROR] Telegram 上传任务失败: $1"
    else
        SEND_TG_MSG Telegram "[ERROR] Failed to upload file to Telegram: $1"
    fi
fi
