arch=$1
docker build --rm -f rust-builder-${arch}.dockerfile -t evolve_backend-builder-${arch}:latest .