#!/bin/sh

# Configure filebrowser
if [ ! -f "/mnt/data/config/filebrowser.db" ]; then
    filebrowser -d /mnt/data/config/filebrowser.db config init
    filebrowser -d /mnt/data/config/filebrowser.db users add ${GLOBAL_USER} ${GLOBAL_PASSWORD} --perm.admin --commands="sv,du,df,free,nslookup,netstat,top,ps"
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        filebrowser -d /mnt/data/config/filebrowser.db users update ${GLOBAL_USER} --locale zh-cn
    fi
else
    if [ "${GLOBAL_LANGUAGE}" = "chs" ]; then
        filebrowser -d /mnt/data/config/filebrowser.db users add ${GLOBAL_USER} ${GLOBAL_PASSWORD} --perm.admin --locale zh-cn --commands="sv,du,df,free,nslookup,netstat,top,ps"
    else
        filebrowser -d /mnt/data/config/filebrowser.db users add ${GLOBAL_USER} ${GLOBAL_PASSWORD} --perm.admin --commands="sv,du,df,free,nslookup,netstat,top,ps"
    fi
    filebrowser -d /mnt/data/config/filebrowser.db users update ${GLOBAL_USER} -p ${GLOBAL_PASSWORD}
fi

filebrowser -d /mnt/data/config/filebrowser.db config set -r /mnt/data -b ${GLOBAL_PORTAL_PATH}/files -p 61801

# Run filebrowser
exec 2>&1
exec filebrowser -d /mnt/data/config/filebrowser.db
