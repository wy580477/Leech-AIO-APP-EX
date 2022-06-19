#!/bin/sh

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

UPLOAD_MODE="$(grep ^ytdlp-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
DRIVE_NAME="$(grep ^drive-name /mnt/data/config/script.conf | cut -d= -f2-)"

DRIVE_NAME_AUTO="$(sed -n '1p' /mnt/data/config/rclone.conf | sed "s/.*\[//g;s/\].*//g;s/\r$//")"
if [ "${DRIVE_NAME}" = "auto" ]; then
    DRIVENAME=${DRIVE_NAME_AUTO}
else
    DRIVENAME=${DRIVE_NAME}
fi

GLOBAL_DRIVE_DIR="$(grep ^drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
YTDLP_DRIVE_DIR="$(grep ^ytdlp-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"

if [ "${YTDLP_DRIVE_DIR}" = "" ]; then
    DRIVE_DIR=${GLOBAL_DRIVE_DIR}/yt-dlp
else
    DRIVE_DIR=${YTDLP_DRIVE_DIR}
fi

REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}"
FILEPATH=$(echo $1 | sed 's:[^/]*$::')
FILENAME=$(basename "$1")
mv "$1" "${FILEPATH}""${FILENAME}"

if [ "${UPLOAD_MODE}" = "disable" ]; then
    echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
else
    JOB_ID="$(curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${FILEPATH}"'","srcRemote":"'"${FILENAME}"'","dstFs":"'"${REMOTE_PATH}"'","dstRemote":"'"${FILENAME}"'","_async":"true"}' 'localhost:61802/operations/'${UPLOAD_MODE}'file' | jq .jobid | sed 's/\"//g')"
    if [ "${JOB_ID}" != "" ]; then
        echo "$(DATE_TIME) [INFO] Successfully send job to rclone: $1 -> ${REMOTE_PATH}"
        curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"${JOB_ID}"'"}' 'localhost:61802/job/status'
    else
        echo "$(DATE_TIME) [ERROR] Failed to send job to rclone: $1"
    fi
fi
