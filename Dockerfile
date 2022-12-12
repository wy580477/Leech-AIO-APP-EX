FROM python:alpine

COPY ./content /workdir/

RUN apk add --no-cache curl caddy jq bash runit tzdata ttyd p7zip findutils \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/*.sh \
    && /workdir/install.sh \
    && rm -rf /workdir/install.sh /tmp/* ${HOME}/.cache ${HOME}/.cargo

ENTRYPOINT ["sh","/workdir/entrypoint.sh"]
