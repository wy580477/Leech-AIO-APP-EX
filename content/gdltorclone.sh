#!/bin/bash

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

UPLOAD_MODE="$(grep ^gallery-dl-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
DELETE_EMPTY_DIR="$(grep ^delete-empty-dir /mnt/data/config/script.conf | cut -d= -f2-)"
DRIVE_NAME="$(grep ^drive-name /mnt/data/config/script.conf | cut -d= -f2-)"
DOWNLOAD_DIR="$(jq '."base-directory"' /mnt/data/config/gallery-dl.conf | sed 's/\"//g;s/\r$//')"

DRIVE_NAME_AUTO="$(sed -n '1p' /mnt/data/config/rclone.conf | sed "s/.*\[//g;s/\].*//g;s/\r$//")"
if [ "${DRIVE_NAME}" = "auto" ]; then
    DRIVENAME=${DRIVE_NAME_AUTO}
else
    DRIVENAME=${DRIVE_NAME}
fi

GLOBAL_DRIVE_DIR="$(grep ^drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
GDL_DRIVE_DIR="$(grep ^gdl-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"

if [ "${GDL_DRIVE_DIR}" = "" ]; then
    DRIVE_DIR=${GLOBAL_DRIVE_DIR}/gallery-dl
else
    DRIVE_DIR=${GDL_DRIVE_DIR}
fi

DL_PATH="$1"
BASE_PATH="${DL_PATH#"${DOWNLOAD_DIR%/}"}"
REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}${BASE_PATH}"

if [ "${UPLOAD_MODE}" = "disable" ]; then
    echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
else
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${DL_PATH}"'","dstFs":"'"${REMOTE_PATH}"'","_async":"true"}' 'localhost:61802/sync/'${UPLOAD_MODE}'' | jq .jobid | sed 's/\"//g')"
    if [ "${JOB_ID}" != "" ]; then
        echo "$(DATE_TIME) [INFO] Successfully send job to rclone: $1 -> ${REMOTE_PATH}"
        curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
    else
        echo "$(DATE_TIME) [ERROR] Failed to send job to rclone: $1"
    fi
fi

if [[ "${DELETE_EMPTY_DIR}" = "true" ]]; then
    find ${DOWNLOAD_DIR} -depth -mindepth 1 -type d -empty -exec rm -vrf {} \; 2>/dev/null
fi
