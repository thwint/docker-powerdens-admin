#!/bin/sh

status_code=$(curl -s -o /dev/null -w "%{http_code}" localhost:9191)

# check uwsgi response code
echo ${status_code}
if [ "${status_code}" -le  "399" ]; then
    exit 0
fi

exit 1