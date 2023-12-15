# Git: git version 2.30.2
# /etc/os-release: Alpine Linux v3.16
# Kernel: Linux ca3abedc4fb1 5.17.15-76051715-generic #202206141358~1655919116~22.04~1db9e34 SMP PREEMPT Wed Jun 22 19 x86_64 Linux
# Build cmd: docker build --no-cache . -t nushell-latest
# Other tags: nushell/alpine-nu:latest, nushell
FROM yuexclusive/alpine:latest
ARG NU_DOWNLOAD_URL="https://github.com/nushell/nushell/releases/download/0.86.0/nu-0.86.0-x86_64-unknown-linux-musl.tar.gz"

LABEL maintainer=nushell

COPY ./env.nu /home/nushell/.config/nushell/env.nu
COPY ./config.nu /home/nushell/.config/nushell/config.nu

RUN echo '/usr/bin/nu' >> /etc/shells \
    && adduser -D -s /usr/bin/nu nushell \
    && mkdir -p /home/nushell/.config/nushell/ \
    && cd /tmp \
    && wget ${NU_DOWNLOAD_URL} \
    && tar -xzf nu* \
    && cd nu*-musl \
    && mv nu /usr/bin/nu \
    && chmod +x /usr/bin/nu \
    && chown -R nushell:nushell /home/nushell/.config/nushell \
    && rm -rf /tmp/*

USER nushell

WORKDIR /home/nushell

ENTRYPOINT ["nu"]