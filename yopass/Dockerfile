FROM debian:bookworm-slim

# Upstream image is distroless/base (glibc) — no shell, no package manager.
# Pull the dynamically-linked binary and bundled web assets out of it and
# rebuild on debian-slim so glibc resolves and we can run the Supervisor
# shell bridge plus a bundled memcached backend.
COPY --from=jhaals/yopass:13.1.0 /yopass-server /yopass-server
COPY --from=jhaals/yopass:13.1.0 /public /public

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    jq \
    curl \
    tzdata \
    memcached \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
