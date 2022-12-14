#!/bin/sh

source /workdir/script_core.sh
APP=Telegram
MSG_PATH="$@"

telegram-upload -d "$1"
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
    echo "[INFO] Successfully upload file to Telegram: $1"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "[INFO] Telegram 上传任务已成功: $1"
    else
        SEND_TG_MSG "${APP}" "[INFO] File successfully uploaded to Telegram : $1"
    fi
else
    echo "[ERROR] Failed to upload file to Telegram: $1"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "[ERROR] Telegram 上传任务失败: $1"
    else
        SEND_TG_MSG "${APP}" "[ERROR] Failed to upload file to Telegram: $1"
    fi
fi 