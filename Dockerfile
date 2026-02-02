FROM debian:trixie-slim AS base

RUN apt-get update && apt-get install -y \
    git \
    golang \
    build-essential \
    libsqlite3-dev \
    scdoc \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder

ARG SOJU_VERSION=master

RUN git clone --depth 1 --branch ${SOJU_VERSION} https://codeberg.org/emersion/soju.git /tmp/soju && \
    cd /tmp/soju && \
    make && \
    make PREFIX=/tmp/soju-bin install

FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/soju-bin/bin/* /usr/local/bin/

RUN mkdir -p /run/soju /var/lib/soju

EXPOSE 6697

CMD ["soju"]
