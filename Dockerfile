FROM python:alpine

COPY ./content /workdir/

RUN apk add --no-cache curl caddy jq bash runit tzdata ttyd p7zip findutils \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/*.sh \
    && /workdir/install.sh \
    && rm -rf /workdir/install.sh /tmp/* ${HOME}/.cache

ENV GLOBAL_USER=admin
ENV GLOBAL_PASSWORD=password
ENV GLOBAL_PORTAL_PATH=/mypath
ENV GLOBAL_LANGUAGE=en
ENV TZ=UTC
ENV PORT=3000

EXPOSE 3000

ENTRYPOINT ["sh","/workdir/entrypoint.sh"]
