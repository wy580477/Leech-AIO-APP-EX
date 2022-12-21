#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

LOCAL_PATH="$1"
APP=yt-dlp
source /workdir/script_core.sh

DEFINITION_PATH() {
    UPLOAD_MODE="$(grep ^ytdlp-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
    YTDLP_DRIVE_DIR="$(grep ^ytdlp-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    FILE_PATH=$(echo ${LOCAL_PATH} | sed 's:[^/]*$::')
    FILE_NAME=$(basename "${LOCAL_PATH}")
    MSG_PATH="${LOCAL_PATH}"
    FOLDER_NAME="${FILE_NAME}"
    DEST_PATH_SUFFIX="${FILE_PATH#"${DOWNLOAD_DIR%/}"}"
    mv "${LOCAL_PATH}" "${FILE_PATH}""${FILE_NAME}"
    if [[ "${YTDLP_DRIVE_DIR}" =~ :/ ]]; then
        REMOTE_PATH_PREFIX="${YTDLP_DRIVE_DIR}"
    else
        if [ "${YTDLP_DRIVE_DIR}" = "" ]; then
            DRIVE_DIR=${GLOBAL_DRIVE_DIR}/yt-dlp
        else
            DRIVE_DIR=${YTDLP_DRIVE_DIR}
        fi
        REMOTE_PATH_PREFIX="${DRIVENAME}:${DRIVE_DIR}"
    fi
    REMOTE_PATH="${REMOTE_PATH_PREFIX}${DEST_PATH_SUFFIX}"
}

UPLOAD_TASK() {
    if [ "${UPLOAD_MODE}" = "disable" ]; then
        echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
        SEND_TG_FINISHED
    else
        SEND_TG_FINISHED_TO_RCLONE
        UPLOAD_FILE
    fi
    if [ "${JOB_ID}" = "" ]; then
        exit 1
    fi
}

GET_PATH
DEFINITION_PATH
UPLOAD_TASK
