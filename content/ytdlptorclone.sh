#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

LOCAL_PATH="$1"
source /workdir/script_core.sh

DEFINITION_PATH() {
    UPLOAD_MODE="$(grep ^ytdlp-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
    YTDLP_DRIVE_DIR="$(grep ^ytdlp-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    FILE_PATH=$(echo ${LOCAL_PATH} | sed 's:[^/]*$::')
    FILE_NAME=$(basename "${LOCAL_PATH}")
    mv "${LOCAL_PATH}" "${FILE_PATH}""${FILE_NAME}"
    if [[ "${YTDLP_DRIVE_DIR}" =~ :/ ]]; then
        REMOTE_PATH="${YTDLP_DRIVE_DIR}"
    else
        if [ "${YTDLP_DRIVE_DIR}" = "" ]; then
            DRIVE_DIR=${GLOBAL_DRIVE_DIR}/yt-dlp
        else
            DRIVE_DIR=${YTDLP_DRIVE_DIR}
        fi
        REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}"
    fi
}

UPLOAD_TASK() {
    if [ "${UPLOAD_MODE}" = "disable" ]; then
        echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
    else
        UPLOAD_FILE
    fi
    if [ "${JOB_ID}" = "" ]; then
        exit 1
    fi
}

GET_PATH
DEFINITION_PATH
UPLOAD_TASK
