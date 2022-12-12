#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

GET_PATH() {
    TELEGRAM_BOT_TOKEN="$(grep ^telegram-bot-token /mnt/data/config/script.conf | cut -d= -f2-)"
    TELEGRAM_CHAT_ID="$(grep ^telegram-chat-id /mnt/data/config/script.conf | cut -d= -f2-)"
    DELETE_EMPTY_DIR="$(grep ^delete-empty-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    DRIVE_NAME="$(grep ^drive-name /mnt/data/config/script.conf | cut -d= -f2-)"
    GLOBAL_DRIVE_DIR="$(grep ^drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    DRIVE_NAME_AUTO="$(sed -n '1p' /mnt/data/config/rclone.conf | sed "s/.*\[//g;s/\].*//g;s/\r$//")"
    if [ "${DRIVE_NAME}" = "auto" ]; then
        DRIVENAME=${DRIVE_NAME_AUTO}
    else
        DRIVENAME=${DRIVE_NAME}
    fi
}

UPLOAD_FILE() {
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${FILE_PATH}"'","srcRemote":"'"${FILE_NAME}"'","dstFs":"'"${REMOTE_PATH}"'","dstRemote":"'"${FILE_NAME}"'","_async":"true"}' 'localhost:61802/operations/'${UPLOAD_MODE}'file' | jq .jobid | sed 's/\"//g')"
    RCLONE_ERROR="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .error | sed 's/\"//g')"
    if [ "${JOB_ID}" != "" ] && [ "${RCLONE_ERROR}" = "" ]; then
        echo "$(DATE_TIME) [INFO] Successfully send job to rclone: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
        RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
        while [[ "${RCLONE_FINISHED}" != "true" ]]; do
            RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
            if [ "${RCLONE_FINISHED}" = "" ]; then
                break
            fi
            sleep 10
        done
        RCLONE_SUCCESS="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .success)"
        if [ "${RCLONE_FINISHED}" = "" ]; then
            echo "[INFO] Fail to get Rclone job status: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Faile to get Rclone job status: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
        elif [ "${RCLONE_SUCCESS}" = "true" ]; then
            echo "[INFO] Rclone job successfully finished: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Rclone job successfully finished: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
        else
            echo "[INFO] Rclone job unsuccessfully finished: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Rclone job unsuccessfully finished: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
        fi
    elif [ "${RCLONE_ERROR}" != "" ]; then
        echo "$(DATE_TIME) [ERROR] Rclone Error: ${RCLONE_ERROR}, ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH} -> ${REMOTE_PATH}"
        SEND_TG_MSG Rclone "[ERROR] Rclone Error: ${RCLONE_ERROR}, ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH} -> ${REMOTE_PATH}"
    else
        curl -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
        echo "$(DATE_TIME) [ERROR] Failed to send job to rclone: ${FILE_PATH}${FILE_NAME}"
        SEND_TG_MSG Rclone "[ERROR] Failed to send job to rclone: ${FILE_PATH}${FILE_NAME}"
    fi
}

UPLOAD_FOLDER() {
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${LOCAL_PATH}"'","dstFs":"'"${REMOTE_PATH}"'","_async":"true"}' 'localhost:61802/sync/'${UPLOAD_MODE}'' | jq .jobid | sed 's/\"//g')"
    RCLONE_ERROR="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .error | sed 's/\"//g')"
    if [ "${JOB_ID}" != "" ] && [ "${RCLONE_ERROR}" = "" ]; then
        echo "$(DATE_TIME) [INFO] Successfully send job to rclone: ${LOCAL_PATH} -> ${REMOTE_PATH}"
        RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
        while [[ "${RCLONE_FINISHED}" != "true" ]]; do
            RCLONE_FINISHED="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .finished)"
            if [ "${RCLONE_FINISHED}" = "" ]; then
                break
            fi
            sleep 10
        done
        RCLONE_SUCCESS="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status' | jq .success)"
        if [ "${RCLONE_FINISHED}" = "" ]; then
            echo "[INFO] Fail to get Rclone job status: ${LOCAL_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Faile to get Rclone job status: ${LOCAL_PATH} -> ${REMOTE_PATH}"
        elif [ "${RCLONE_SUCCESS}" = "true" ]; then
            echo "[INFO] Rclone job successfully finished: ${LOCAL_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Rclone job successfully finished: ${LOCAL_PATH} -> ${REMOTE_PATH}"
        else
            echo "[INFO] Rclone job unsuccessfully finished: ${LOCAL_PATH} -> ${REMOTE_PATH}"
            SEND_TG_MSG Rclone "[INFO] Rclone job unsuccessfully finished: ${LOCAL_PATH} -> ${REMOTE_PATH}"
        fi
    elif [ "${RCLONE_ERROR}" != "" ]; then
        echo "$(DATE_TIME) [ERROR] Rclone Error: ${RCLONE_ERROR}, ${LOCAL_PATH} -> ${REMOTE_PATH}"
        SEND_TG_MSG Rclone "[ERROR] Rclone Error: ${RCLONE_ERROR}, ${LOCAL_PATH} -> ${REMOTE_PATH}"
    else
        curl -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
        echo "$(DATE_TIME) [ERROR] Failed to send job to rclone: ${LOCAL_PATH}"
        SEND_TG_MSG Rclone "[ERROR] Failed to send job to rclone: ${LOCAL_PATH}"
    fi
}

SEND_TG_MSG() {
    if [ "${TELEGRAM_CHAT_ID}" != "" ]; then
        title="$1"
        timestamp="$(DATE_TIME)"
        msg="$title $timestamp\n$(echo "$2" | sed -e 's|\\|\\\\|g' -e 's|\n|\\n|g' -e 's|\t|\\t|g' -e 's|\"|\\"|g')"
        entities="[{\"offset\":0,\"length\":${#title},\"type\":\"bold\"},{\"offset\":$((${#title} + 1)),\"length\":${#timestamp},\"type\":\"italic\"}]"
        data="{\"chat_id\":\"$TELEGRAM_CHAT_ID\",\"text\":\"$msg\",\"entities\":$entities,\"disable_notification\": true}"
        curl -s -o /dev/null -H 'Content-Type: application/json' -X POST -d "$data" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
    fi
}

SEND_TG_FINISHED() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} 下载已完成"
    else
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} download completed"
    fi
}

SEND_TG_FINISHED_TO_RCLONE() {
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} 下载已完成并发送上传任务至 Rclone"
    else
        SEND_TG_MSG "${APP}" "${FOLDER_NAME} download completed and send upload job to Rclone"
    fi
}

CLEAN_EMPTY_DIR() {
    if [ "${DELETE_EMPTY_DIR}" = "true" ]; then
        find ${DOWNLOAD_DIR} -depth -mindepth 1 -type d -empty -exec rm -vrf {} \; 2>/dev/null
    fi
}
