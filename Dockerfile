FROM python:alpine

COPY ./content /workdir/

RUN apk add --no-cache curl caddy jq bash runit tzdata ttyd p7zip findutils wget \
    && chmod +x /workdir/service/*/run /workdir/service/*/log/run /workdir/*.sh \
    && /workdir/install.sh \
    && rm -rf /workdir/install.sh /tmp/* ${HOME}/.cache ${HOME}/.cargo

ENV PORT=3000

EXPOSE 3000

ENTRYPOINT ["sh","/workdir/entrypoint.sh"]
