arch=$1

docker run --cpus=8 --network="host" -it --name evolve_backend-builder-${arch}-container -w /work/evolve_backend -v `cd ../..;pwd`:/work evolve_backend-builder-${arch}:latest cargo build --target=${arch}-unknown-linux-musl --release
docker commit evolve_backend-builder-${arch}-container evolve_backend-builder-${arch}:latest
docker rm -f evolve_backend-builder-${arch}-container