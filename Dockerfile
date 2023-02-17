FROM node:lts-alpine as builder

WORKDIR /metube

RUN apk add git && \
    git clone https://github.com/alexta69/metube && \
    mv ./metube/ui/* ./ && \
    npm ci && \
    node_modules/.bin/ng build --configuration production


FROM ghcr.io/wy580477/leech-aio-app-ex:1.6.13 AS caddy_workaround


FROM python:3.8-alpine AS dist

COPY ./content /workdir/

WORKDIR /app

ENV GLOBAL_USER=admin
ENV GLOBAL_PASSWORD=password
ENV CADDY_DOMAIN=http://localhost
ENV CADDY_EMAIL=internal
ENV CADDY_WEB_PORT=8080
ENV GLOBAL_LANGUAGE=en
ENV GLOBAL_PORTAL_PATH=/portal
ENV PATH="/root/.local/bin:$PATH"
ENV XDG_CONFIG_HOME=/mnt/data/config
ENV DOWNLOAD_DIR=/mnt/data/videos
ENV STATE_DIR=/mnt/data/videos/.metube

RUN apk add --no-cache --update curl jq ffmpeg runit tzdata fuse p7zip bash findutils \
    && python3 -m pip install --user --no-cache-dir pipx \
    && apk add --no-cache --update --virtual .build-deps git curl-dev gcc g++ libffi-dev musl-dev jpeg-dev \
    && pip install --no-cache-dir pipenv \
    && git clone https://github.com/alexta69/metube \
    && mv ./metube/Pipfile* ./metube/app ./metube/favicon ./ \
    && pipenv install --system --deploy --clear \
    && pip uninstall pipenv -y \
    && pipx install --pip-args='--no-cache-dir' pyload-ng[plugins] \
    && pipx install --pip-args='--no-cache-dir' gallery-dl \
    && apk del .build-deps \
    && wget -O - https://github.com/mayswind/AriaNg/releases/download/1.3.2/AriaNg-1.3.2.zip | busybox unzip -qd /workdir/ariang - \
    && wget -O - https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip | busybox unzip -qd /workdir/rcloneweb - \
    && wget -O - https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip | busybox unzip -qd /workdir/homer - \
    && wget -O - https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip | busybox unzip -qd /workdir - \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/aria2/*.sh /workdir/*.sh /workdir/dlpr /workdir/gdlr \
    && /workdir/install.sh \
    && rm -rf metube /workdir/install.sh /tmp/* ${HOME}/.cache /var/cache/apk/* \
    && mv /workdir/ytdlp*.sh /workdir/dlpr /workdir/gdlr /usr/bin/ \
    && ln -s /workdir/service/* /etc/service/

COPY --from=caddy_workaround /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /metube/dist/metube /app/ui/dist/metube

VOLUME /mnt/data

ENTRYPOINT ["sh","-c","/workdir/entrypoint.sh"]
