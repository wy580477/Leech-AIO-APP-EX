#!/bin/bash
#
# Created by wy580477 for customized container <https://github.com/wy580477>
#

LOCAL_PATH="$1"
source /workdir/script_core.sh

DEFINITION_PATH() {
    UPLOAD_MODE="$(grep ^gallery-dl-upload-mode /mnt/data/config/script.conf | cut -d= -f2-)"
    DOWNLOAD_DIR="$(jq '."base-directory"' /mnt/data/config/gallery-dl.conf | sed 's/\"//g;s/\r$//')"
    GDL_DRIVE_DIR="$(grep ^gdl-drive-dir /mnt/data/config/script.conf | cut -d= -f2-)"
    BASE_PATH="${LOCAL_PATH#"${DOWNLOAD_DIR%/}"}"
    if [[ "${GDL_DRIVE_DIR}" =~ :/ ]]; then
        REMOTE_PATH="${GDL_DRIVE_DIR}${BASE_PATH}"
    else
        if [ "${GDL_DRIVE_DIR}" = "" ]; then
            DRIVE_DIR=${GLOBAL_DRIVE_DIR}/gallery-dl
        else
            DRIVE_DIR=${GDL_DRIVE_DIR}
        fi
        REMOTE_PATH="${DRIVENAME}:${DRIVE_DIR}${BASE_PATH}"
    fi
}

UPLOAD_TASK() {
    if [ "${UPLOAD_MODE}" = "disable" ]; then
        echo "$(DATE_TIME) [INFO] Auto-upload to Rclone remote disabled"
    else
        UPLOAD_FOLDER
    fi
    if [ "${JOB_ID}" = "" ]; then
        exit 1
    fi
}

GET_PATH
DEFINITION_PATH
UPLOAD_TASK
CLEAN_EMPTY_DIR
