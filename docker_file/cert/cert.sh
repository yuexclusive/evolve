# scp -r ./cert root@159.138.105.173:/root
docker run -itd --rm --name nginx-challenge -v ${PWD}/nginx_challenge.conf:/etc/nginx/nginx.conf -v ${PWD}:/letsencrypt -p 80:80 nginx
docker build . -t certbot
docker run -itd --rm --name certbot -v ${PWD}:/letsencrypt -v ${PWD}/certs:/etc/letsencrypt certbot/certbot certonly
# certbot renew --dry-run
# docker exec -it nginx sh -c "nginx -s reload"
docker run -itd --rm --name nginx -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf -v ${PWD}/certs:/etc/letsencrypt -p 443:443 nginx
