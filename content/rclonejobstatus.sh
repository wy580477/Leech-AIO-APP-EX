#!/bin/bash

curl -s -u ${GLOBAL_USER}:${GLOBAL_PASSWORD} -H "Content-Type: application/json" -f -X POST -d '{"jobid":"'"$1"'"}' 'localhost:61802/job/status'