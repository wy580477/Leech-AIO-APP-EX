#!/bin/sh

curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"$2"'","dstFs":"'"$3"'","_async":"true"}' 'localhost:61802/sync/'$1''
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]; then
    echo "[INFO] Successfully send job to rclone: $2 -> $3"
else
    echo "[ERROR] Failed to send job to rclone: $2"
fi 