FROM alexta69/metube:latest

COPY ./content /workdir/

ENV GLOBAL_USER=admin
ENV GLOBAL_PASSWORD=password
ENV CADDY_DOMAIN=http://localhost
ENV CADDY_EMAIL=internal
ENV CADDY_WEB_PORT=8080
ENV GLOBAL_LANGUAGE=en
ENV GLOBAL_PORTAL_PATH=/portal
ENV TZ=UTC
ENV PATH="/root/.local/bin:$PATH"
ENV XDG_CONFIG_HOME=/mnt/data/config
ENV DOWNLOAD_DIR=/mnt/data/videos
ENV STATE_DIR=/mnt/data/videos/.metube

RUN apk add --no-cache curl jq runit tzdata fuse p7zip bash findutils \
    && python3 -m pip install --user --no-cache-dir pipx \
    && apk add --no-cache --virtual .build-deps curl-dev gcc libffi-dev musl-dev jpeg-dev \
    && pipx install --pip-args='--no-cache-dir' pyload-ng[plugins] \
    && pipx install --pip-args='--no-cache-dir' gallery-dl \
    && apk del .build-deps \
    && wget -O - https://github.com/mayswind/AriaNg/releases/download/1.3.2/AriaNg-1.3.2.zip | busybox unzip -qd /workdir/ariang - \
    && wget -O - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip | busybox unzip -qd /workdir/rcloneweb - \
    && wget -O - https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip | busybox unzip -qd /workdir/homer - \
    && wget -O - https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip | busybox unzip -qd /workdir - \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/aria2/*.sh /workdir/*.sh /workdir/dlpr /workdir/gdlr \
    && /workdir/install.sh \
    && rm -rf /workdir/install.sh /tmp/* ${HOME}/.cache \
    && mv /workdir/ytdlp*.sh /workdir/dlpr /workdir/gdlr /usr/bin/ \
    && ln -s /workdir/service/* /etc/service/

VOLUME /mnt/data

ENTRYPOINT ["sh","-c","/workdir/entrypoint.sh"]
