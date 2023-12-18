# Git: git version 2.30.2
# /etc/os-release: Alpine Linux v3.16
# Kernel: Linux ca3abedc4fb1 5.17.15-76051715-generic #202206141358~1655919116~22.04~1db9e34 SMP PREEMPT Wed Jun 22 19 x86_64 Linux
# Build cmd: docker build --no-cache . -t nushell-latest
# Other tags: nushell/alpine-nu:latest, nushell
FROM docker:cli
ARG NU_DOWNLOAD_URL="https://github.com/nushell/nushell/releases/download/0.88.1/nu-0.88.1-x86_64-unknown-linux-musl.tar.gz"

COPY ./env.nu /root/.config/nushell/env.nu
COPY ./config.nu /root/.config/nushell/config.nu

COPY packup.nu /work/packup.nu
COPY Makefile /work/.bak/Makefile

RUN echo '/usr/bin/nu' >> /etc/shells \
    && cd /tmp \
    && wget ${NU_DOWNLOAD_URL} \
    && tar -xzf nu* \
    && cd nu*-musl \
    && mv nu /usr/bin/nu \
    && rm -rf /tmp/*

RUN apk add zip

RUN apk add unzip

run apk add tzdata
run ln /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
run echo "Asia/Shanghai" > /etc/timezone

WORKDIR /work