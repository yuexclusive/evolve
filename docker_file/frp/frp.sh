# scp -r ./frp root@159.138.105.173:/root
docker build -t frp .

docker run -itd -v ${PWD}/frps.ini:/frps.ini -p 8080:8080 -p 7000:7000 frp