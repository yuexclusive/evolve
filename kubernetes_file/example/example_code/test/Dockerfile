from alpine
workdir /app
add test .
add home.html .

# log
run mkdir log

# timezone
run apk add tzdata
run cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
run echo "Asia/Shanghai" >  /etc/timezone


cmd ["/app/test"]