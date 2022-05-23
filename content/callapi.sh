#!/bin/sh

curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"srcFs":"'"$2"'","dstFs":"'"$3"'","_async":"true"}' 'localhost:61802/sync/'$1''