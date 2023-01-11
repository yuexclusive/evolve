from alpine
workdir /app
add cache .

# log
run mkdir log

# timezone
run apk add tzdata
run cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
run echo "Asia/Shanghai" >  /etc/timezone


cmd ["sh","-c","GIN_MODE=release /app/cache"]