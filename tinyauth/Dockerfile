FROM ghcr.io/steveiliop56/tinyauth:v4.1.0

# Switch to root to install dependencies
USER root

# Install requirements
RUN apk add --no-cache \
    bash \
    jq \
    curl \
    tzdata

# Copy root filesystem
COPY rootfs/run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
