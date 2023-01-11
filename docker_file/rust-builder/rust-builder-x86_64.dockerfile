FROM messense/rust-musl-cross:x86_64-musl
# ENV DATABASE_URL postgres://postgres:123456@192.168.2.149:5432/evolve
RUN rustup default nightly
RUN rustup target add x86_64-unknown-linux-musl
RUN apt update
# RUN apt install -y musl-tools musl-dev
RUN apt install -y pkg-config libssl-dev
# RUN apt install build-essential
RUN update-ca-certificates

# cargo registry
RUN echo "[source.crates-io]" >>~/.cargo/config
RUN echo "registry = \"https://mirrors.ustc.edu.cn/crates.io-index\"" >>~/.cargo/config
