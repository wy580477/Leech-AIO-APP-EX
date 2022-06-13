#!/bin/sh

UPLOAD_MODE="$(grep ^qbit-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
DELETE_EMPTY_DIR="$(grep ^delete-empty-dir /mnt/data/config/script.conf | cut -d= -f2-)"
DRIVE_NAME="$(grep ^drive-name /mnt/data/config/script.conf | cut -d= -f2-)"

DRIVE_NAME_AUTO="$(sed -n '1p' /mnt/data/config/rclone.conf | sed "s/.*\[//g;s/\].*//g;s/\r$//")"
if [ "${DRIVE_NAME}" = "auto" ]; then
    DRIVENAME=${DRIVE_NAME_AUTO}
else
    DRIVENAME=${DRIVE_NAME}
fi

GLOBAL_DRIVE_DIR="$(grep ^drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
QBIT_DRIVE_DIR="$(grep ^qbit-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"

if [ "${QBIT_DRIVE_DIR}" = "" ]; then
    DRIVE_DIR=${GLOBAL_DRIVE_DIR}/qBittorrent
else
    DRIVE_DIR=${QBIT_DRIVE_DIR}
fi

REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}"
FILE_NAME="$(basename "$1")"
FILE_PATH="$(echo $1 | sed 's:[^/]*$::')"

if [ "${UPLOAD_MODE}" = "disable" ]; then
    echo "[INFO] Auto-upload to Rclone remote disabled"
elif [ -f "$1" ]; then
    curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"${FILE_PATH}"'","srcRemote":"'"${FILE_NAME}"'","dstFs":"'"${REMOTE_PATH}"'","dstRemote":"'"${FILE_NAME}"'","_async":"true"}' 'localhost:61802/operations/'${UPLOAD_MODE}'file'
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -eq 0 ]; then
        echo "[INFO] Successfully send job to rclone: $1 -> ${REMOTE_PATH}"
    else
        echo "[ERROR] Failed to send job to rclone: $1"
    fi
else
    curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"$1"'","dstFs":"'"${REMOTE_PATH}"'/'"$2"'","_async":"true"}' 'localhost:61802/sync/'${UPLOAD_MODE}''
    EXIT_CODE=$?
    if [ ${EXIT_CODE} -eq 0 ]; then
        echo "[INFO] Successfully send job to rclone: $1 -> ${REMOTE_PATH}"
    else
        echo "[ERROR] Failed to send job to rclone: $1"
    fi
fi

if [[ "${DELETE_EMPTY_DIR}" = "true" ]]; then
    find /mnt/data/qbit_downloads -depth -mindepth 1 -type d -empty -exec rm -vrf {} \; 2>/dev/null
fi
