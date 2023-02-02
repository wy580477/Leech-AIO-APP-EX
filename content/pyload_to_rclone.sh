#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

LOCAL_PATH="$3"
FILE_NAME="$2"
FOLDER_NAME="${FILE_NAME}"
APP=pyload
source /workdir/script_core.sh

DEFINITION_PATH() {
    UPLOAD_MODE="$(grep ^pyload-download-finished-upload-mode /mnt/data/config/script.conf | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    DOWNLOAD_DIR="$(grep ^'.*folder storage_folder' /workdir/.pyload/settings/pyload.cfg | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    PYLOAD_DRIVE_DIR="$(grep ^pyload-drive-dir /mnt/data/config/script.conf | cut -d= -f2- | sed "s|^[ \t]*||g;s|\r$||")"
    FILE_PATH=$(echo ${LOCAL_PATH} | sed 's:[^/]*$::')
    MSG_PATH="${FILE_PATH}${FILE_NAME}"
    DEST_PATH_SUFFIX="${FILE_PATH#"${DOWNLOAD_DIR%/}"}"
    if [[ "${PYLOAD_DRIVE_DIR}" =~ :/ ]]; then
        REMOTE_PATH="${PYLOAD_DRIVE_DIR}${DEST_PATH_SUFFIX}"
    else
        if [ "${PYLOAD_DRIVE_DIR}" = "" ]; then
            DRIVE_DIR=${GLOBAL_DRIVE_DIR}/pyload
        else
            DRIVE_DIR=${PYLOAD_DRIVE_DIR}
        fi
        REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}${DEST_PATH_SUFFIX}"
    fi
}

UPLOAD_TASK() {
    if [ "${UPLOAD_MODE}" = "disable" ]; then
        SEND_TG_FINISHED
        echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
    else
        SEND_TG_FINISHED_TO_RCLONE
        UPLOAD_FILE
    fi
}

GET_PATH
DEFINITION_PATH
UPLOAD_TASK
CLEAN_EMPTY_DIR
