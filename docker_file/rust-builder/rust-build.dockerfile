FROM rust:latest as builder
workdir /app
# for rocket
run rustup install nightly 
run rustup default nightly 
RUN rustup target add aarch64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates
copy ./ .
run cargo build --target aarch64-unknown-linux-musl --release

FROM scratch
workdir /app
copy --from=builder /app/target/aarch64-unknown-linux-musl/release/foo .
CMD ["/app/foo"]