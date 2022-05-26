#!/bin/sh

sleep 10
sed -i 's|delete\"\ =.*|delete"\ =\ False|g' /workdir/.pyload/settings/plugins.cfg
sv restart 6