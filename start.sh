#!/bin/sh

if [ -n "/opt/PowerDNS-Admin/app/static/generated" ]
then
  echo Building assets
  flask assets build
fi

function waitAndInitMySql {
    while ! mysqladmin ping --host=${DB_HOST} --user=${DB_USER} --port=${DB_PORT} --password=${DB_PASSWORD} --silent; do
        sleep 1
    done

    DB_CMD="mysql --host=${DB_HOST} --user=${DB_USER} --port=${DB_PORT} --password=${DB_PASSWORD} --silent"

    if [ "$(echo "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \"${DB_NAME}\";" | ${DB_CMD})" -le 1 ]; then
        echo Database is empty. Initializing database ...
        flask db upgrade
    fi

}
# traps to properly shutdown powerdns
trap "echo q > /run/uwsgi/uwsgi.fifo" SIGHUP SIGINT SIGTERM

waitAndInitMySql

uwsgi --ini /etc/uwsgi/conf.d/pdnsa.ini
