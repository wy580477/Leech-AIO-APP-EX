FROM python:alpine

COPY ./content /workdir/

RUN apk add --no-cache curl caddy jq bash runit tzdata ttyd p7zip ffmpeg findutils \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/*.sh \
    && /workdir/install.sh \
    && rm -rf /workdir/install.sh /tmp/* ${HOME}/.cache ${HOME}/.cargo

ENV PORT=3000
ENV GLOBAL_USER=admin
ENV GLOBAL_PASSWORD=password
ENV GLOBAL_LANGUAGE=en
ENV GLOBAL_PORTAL_PATH=/mypath
ENV TZ=UTC

EXPOSE 3000

ENTRYPOINT ["sh","/workdir/entrypoint.sh"]
