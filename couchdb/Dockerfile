FROM couchdb:3.4.2

# Run as root; upstream /docker-entrypoint.sh drops privileges via `gosu couchdb`.
USER root

# Install requirements (bash + openssl already present in base image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs/run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
