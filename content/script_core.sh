#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

GET_PATH() {
    SCRIPT_CONF="/mnt/data/config/script.conf"
    TELEGRAM_BOT_TOKEN="$(grep ^telegram-bot-token "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TELEGRAM_CHAT_ID="$(grep ^telegram-chat-id "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TELEGRAM_TITLE="$(grep ^telegram-notification-title "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TG_PROXY="$(grep ^telegram-proxy "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TG_EXCLUDE_FILE_EXTENSION="$(grep ^telegram-exclude-file-extension "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    TG_INCLUDE_FILE_EXTENSION="$(grep ^telegram-include-file-extension "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    DELETE_EMPTY_DIR="$(grep ^delete-empty-dir "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    DRIVE_NAME="$(grep ^drive-name "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    GLOBAL_DRIVE_DIR="$(grep ^drive-dir "${SCRIPT_CONF}" | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    DRIVE_NAME_AUTO="$(sed -n '1p' /mnt/data/config/rclone.conf | sed "s/.*\[//g;s/\].*//g;s/\r$//")"
    if [ "${DRIVE_NAME}" = "auto" ]; then
        DRIVENAME=${DRIVE_NAME_AUTO}
    else
        DRIVENAME=${DRIVE_NAME}
    fi
}

RCLONE_MSG() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        RCLONE_SEND_MSG="已成功发生任务至 Rclone"
        RCLONE_NO_STATUS_MSG="无法获取 Rclone 任务状态"
        RCLONE_SUCCESS_MSG="Rclone 任务已成功完成"
        RCLONE_ERROR_MSG="Rclone 错误"
        RCLONE_FAIL_MSG="无法发送任务至 Rclone"
    else
        RCLONE_SEND_MSG="Successfully send job to Rclone"
        RCLONE_NO_STATUS_MSG="Faile to get Rclone job status"
        RCLONE_SUCCESS_MSG="Rclone job successfully finished"
        RCLONE_ERROR_MSG="Rclone Error"
        RCLONE_FAIL_MSG="Failed to send job to Rclone"
    fi
}

RCLONE_PROCESS() {
    RCLONE_MSG
    RCLONE_ERROR="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .error | sed 's/\"//g')"
    if [[ "${JOB_ID}" != "" ]] && [[ "${RCLONE_ERROR}" = "" ]]; then
        echo "$(DATE_TIME) [INFO] ${RCLONE_SEND_MSG}: ${MSG_PATH} -> ${REMOTE_PATH}"
        RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
        while [[ "${RCLONE_FINISHED}" = "false" ]]; do
            RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
            RCLONE_ERROR="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .error | sed 's/\"//g')"
            sleep 10
        done
        RCLONE_SUCCESS="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .success)"
        if [ "${RCLONE_FINISHED}" = "" ]; then
            echo "[INFO] ${RCLONE_NO_STATUS_MSG}: ${MSG_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] ${RCLONE_NO_STATUS_MSG}: ${MSG_PATH} -> ${REMOTE_PATH}"
        elif [ "${RCLONE_ERROR}" != "" ]; then
            echo "$(DATE_TIME) [ERROR] ${RCLONE_ERROR_MSG}: ${RCLONE_ERROR}, ${MSG_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[ERROR] ${RCLONE_ERROR_MSG}: ${RCLONE_ERROR}, ${MSG_PATH} -> ${REMOTE_PATH}"
        elif [ "${RCLONE_SUCCESS}" = "true" ]; then
            echo "[INFO] ${RCLONE_SUCCESS_MSG}: ${MSG_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] ${RCLONE_SUCCESS_MSG}: ${MSG_PATH} -> ${REMOTE_PATH}"
        fi
    elif [ "${RCLONE_ERROR}" != "" ]; then
        echo "$(DATE_TIME) [ERROR] ${RCLONE_ERROR_MSG}: ${RCLONE_ERROR}, ${MSG_PATH} -> ${REMOTE_PATH}"
        SEND_TG_MSG Rclone "[ERROR] ${RCLONE_ERROR_MSG}: ${RCLONE_ERROR}, ${MSG_PATH} -> ${REMOTE_PATH}"
    else
        curl -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
        echo "$(DATE_TIME) [ERROR] ${RCLONE_FAIL_MSG}: ${MSG_PATH}"
        SEND_TG_MSG Rclone "[ERROR] ${RCLONE_FAIL_MSG}: ${FILE_PATH}${FILE_NAME}"
    fi
}

UPLOAD_FILE() {
    if [ ! -f /mnt/data/config/rclone.conf ]; then
        if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
            echo "$(DATE_TIME) [ERROR] 未找到 Rclone 配置文件"
            SEND_TG_MSG Rclone "[ERROR] 未找到 Rclone 配置文件"
        else
            echo "$(DATE_TIME) [ERROR] Rclone config file not found"
            SEND_TG_MSG Rclone "[ERROR] Rclone config file not found"
        fi
        exit 1
    fi
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${FILE_PATH}"'","srcRemote":"'"${FILE_NAME}"'","dstFs":"'"${REMOTE_PATH}"'","dstRemote":"'"${FILE_NAME}"'","_async":"true"}' 'localhost:61802/operations/'${UPLOAD_MODE}'file' | jq .jobid | sed 's/\"//g')"
    RCLONE_PROCESS
}

UPLOAD_FOLDER() {
    if [ ! -f /mnt/data/config/rclone.conf ]; then
        if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
            echo "$(DATE_TIME) [ERROR] 未找到 Rclone 配置文件"
            SEND_TG_MSG Rclone "[ERROR] 未找到 Rclone 配置文件"
        else
            echo "$(DATE_TIME) [ERROR] Rclone config file not found"
            SEND_TG_MSG Rclone "[ERROR] Rclone config file not found"
        fi
        exit 1
    fi
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${LOCAL_PATH}"'","dstFs":"'"${REMOTE_PATH}"'","_async":"true"}' 'localhost:61802/sync/'${UPLOAD_MODE}'' | jq .jobid | sed 's/\"//g')"
    RCLONE_PROCESS
}

SEND_TG_MSG() {
    if [[ -f "${MSG_PATH}" ]] && [[ "${TG_EXCLUDE_FILE_EXTENSION}" != "" ]] && [[ "${FILE_NAME}" =~ \.(${TG_EXCLUDE_FILE_EXTENSION})$ ]]; then
        exit 0
    elif [[ -f "${MSG_PATH}" ]] && [[ "${TG_INCLUDE_FILE_EXTENSION}" != "" ]] && [[ ! "${FILE_NAME}" =~ \.(${TG_INCLUDE_FILE_EXTENSION})$ ]]; then
        exit 0
    fi
    if [ "${TELEGRAM_CHAT_ID}" != "" ]; then
        if [ "${TG_PROXY}" != "" ]; then
            PROXY_PARAM="-x ${TG_PROXY}"
        fi
        title="$TELEGRAM_TITLE $1"
        timestamp="$(DATE_TIME)"
        msg="$title $timestamp\n$(echo "$2" | sed -e 's|\\|\\\\|g' -e 's|\n|\\n|g' -e 's|\t|\\t|g' -e 's|\"|\\"|g')"
        entities="[{\"offset\":0,\"length\":${#title},\"type\":\"bold\"},{\"offset\":$((${#title} + 1)),\"length\":${#timestamp},\"type\":\"italic\"}]"
        data="{\"chat_id\":\"$TELEGRAM_CHAT_ID\",\"text\":\"$msg\",\"entities\":$entities,\"disable_notification\": true}"
        curl -s "${PROXY_PARAM}" -o /dev/null -H 'Content-Type: application/json' -X POST -d "$data" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
    fi
}

SEND_TG_FINISHED() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} 任务已完成"
    else
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} task completed"
    fi
}

SEND_TG_FINISHED_TO_RCLONE() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} 任务已完成并发送上传任务至 Rclone"
    else
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} task completed and send upload job to Rclone"
    fi
}

CLEAN_EMPTY_DIR() {
    if [ "${DELETE_EMPTY_DIR}" = "true" ]; then
        find ${DOWNLOAD_DIR} -depth -mindepth 1 -type d -empty -exec rm -vrf {} \; 2>/dev/null
    fi
}
