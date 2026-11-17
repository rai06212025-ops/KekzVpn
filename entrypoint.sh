#!/bin/sh
set -e

PORT=${PORT:-8080}
sed -i "s/listen\s*[0-9]*;/listen $PORT;/g" /usr/local/openresty/nginx/conf/nginx.conf

/usr/local/bin/xray run -config /etc/xray.json &
XRAY_PID=$!

exec /usr/local/openresty/bin/openresty -g "daemon off;"

wait $XRAY_PID
kill -TERM 1
