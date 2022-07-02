#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

GET_PATH() {
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
    if [ "${JOB_ID}" != "" ]; then
        echo "[INFO] Successfully send job to rclone: ${FILE_PATH}${FILE_NAME} -> ${REMOTE_PATH}"
        curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
    else
        echo "[ERROR] Failed to send job to rclone: ${FILE_PATH}${FILE_NAME}"
    fi
}

UPLOAD_FOLDER() {
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${LOCAL_PATH}"'","dstFs":"'"${REMOTE_PATH}"'","_async":"true"}' 'localhost:61802/sync/'${UPLOAD_MODE}'' | jq .jobid | sed 's/\"//g')"
    if [ "${JOB_ID}" != "" ]; then
        echo "$(DATE_TIME) [INFO] Successfully send job to rclone: ${LOCAL_PATH} -> ${REMOTE_PATH}"
        curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
    else
        echo "$(DATE_TIME) [ERROR] Failed to send job to rclone: ${LOCAL_PATH}"
    fi
}

CLEAN_EMPTY_DIR() {
    if [ "${DELETE_EMPTY_DIR}" = "true" ]; then
        find ${DOWNLOAD_DIR} -depth -mindepth 1 -type d -empty -exec rm -vrf {} \; 2>/dev/null
    fi
}
