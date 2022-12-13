#!/bin/sh

source /workdir/script_core.sh
APP=Telegram

telegram-upload -d "$@"
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
    echo "[INFO] Successfully upload file to Telegram: $@"
else
    echo "[ERROR] Failed to upload file to Telegram: $@"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "[ERROR] Telegram 上传任务失败: $@"
    else
        SEND_TG_MSG "${APP}" "[ERROR] Failed to upload file to Telegram: $@"
    fi
fi 