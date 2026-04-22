FROM alpine:3.20

# Upstream image is distroless — no shell, no package manager. Pull the static
# binary and bundled web assets out of it and rebuild on Alpine so we can run
# the Supervisor-options shell bridge and bundle memcached as the backend.
COPY --from=jhaals/yopass:13.1.0 /yopass-server /yopass-server
COPY --from=jhaals/yopass:13.1.0 /public /public

RUN apk add --no-cache \
    bash \
    jq \
    curl \
    tzdata \
    memcached \
    openssl

COPY rootfs/run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
