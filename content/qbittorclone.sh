#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

LOCAL_PATH="$1"
APP=qBittorrent
source /workdir/script_core.sh

DEFINITION_PATH() {
    UPLOAD_MODE="$(grep ^qbit-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
    DOWNLOAD_DIR="$(grep ^'Session\\\DefaultSavePath' /mnt/data/config/qBittorrent/config/qBittorrent.conf | cut -d= -f2- | sed "s/\r$//")"
    QBIT_DRIVE_DIR="$(grep ^qbit-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    FILE_NAME="$(basename "${LOCAL_PATH}")"
    FOLDER_NAME="${FILE_NAME}"
    MSG_PATH="${LOCAL_PATH}"
    FILE_PATH="$(echo ${LOCAL_PATH} | sed 's:[^/]*$::')"
    DEST_PATH_SUFFIX="${FILE_PATH#"${DOWNLOAD_DIR%/}"}"
    if [[ "${QBIT_DRIVE_DIR}" =~ :/ ]]; then
        REMOTE_PATH_PREFIX="${QBIT_DRIVE_DIR}"
    else
        if [ "${QBIT_DRIVE_DIR}" = "" ]; then
            DRIVE_DIR=${GLOBAL_DRIVE_DIR}/qBittorrent
        else
            DRIVE_DIR=${QBIT_DRIVE_DIR}
        fi
        REMOTE_PATH_PREFIX="${DRIVENAME}:${DRIVE_DIR}"
    fi
    if [ -f "${LOCAL_PATH}" ]; then
        REMOTE_PATH="${REMOTE_PATH_PREFIX}${DEST_PATH_SUFFIX}"
    else
        REMOTE_PATH="${REMOTE_PATH_PREFIX}${DEST_PATH_SUFFIX}${FILE_NAME}"
    fi
}

UPLOAD_TASK() {
    if [ "${UPLOAD_MODE}" = "disable" ]; then
        SEND_TG_FINISHED
        echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
    elif [ -f "${LOCAL_PATH}" ]; then
        SEND_TG_FINISHED_TO_RCLONE
        UPLOAD_FILE
    else
        SEND_TG_FINISHED_TO_RCLONE
        UPLOAD_FOLDER
    fi
}

GET_PATH
DEFINITION_PATH
UPLOAD_TASK
CLEAN_EMPTY_DIR
