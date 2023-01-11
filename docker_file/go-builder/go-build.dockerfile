from alpine
workdir /work
run apk update && apk add tzdata
run ln /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
run echo "Asia/Shanghai" > /etc/timezone
run ln -s /lib/ld-musl-aarch64.so.1 /lib/ld-linux-aarch64.so.1 
run wget https://go.dev/dl/go1.17.6.linux-arm64.tar.gz
run tar -C /usr/local -xzvf go1.17.6.linux-arm64.tar.gz
run mv /usr/local/go/bin/* /usr/local/bin
run rm -fr *
entrypoint ["/bin/sh","-c","go build -o test .;/work/test"]