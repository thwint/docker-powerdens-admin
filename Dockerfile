FROM quay.io/thwint/alpine-base:3.10-0

LABEL maintainer="Tom Winterhalder <tom.winterhalder@gmail.com>"

ARG PDNS_ADMIN_VERSION=0.1
ENV PDNS_ADMIN_VERSION=${PDNS_ADMIN_VERSION}
ENV FLASK_APP=/opt/PowerDNS-Admin/app/__init__.py

#ADD https://github.com/ngoduykhanh/PowerDNS-Admin/archive/v${PDNS_ADMIN_VERSION}.zip /opt/
ADD https://github.com/ngoduykhanh/PowerDNS-Admin/archive/master.zip /opt/

RUN apk add --no-cache \
    python3 python3-dev uwsgi uwsgi-python3 uwsgi mysql-client \
    nodejs yarn build-base pkgconfig libffi-dev openldap-dev \
    mariadb-dev postgresql-dev xmlsec-dev libxslt-dev && \
    python3 -m ensurepip && \
    pip3 install -U pip wheel setuptools && \
    pip3 install --upgrade pip && \
    rm -rf /var/cache/apk/* && \
    unzip -d /opt /opt/*.zip && \
    rm /opt/master.zip  && \
    mv /opt/* /opt/PowerDNS-Admin

COPY *.sh /
COPY config.py /opt/PowerDNS-Admin
COPY pdnsa.ini /etc/uwsgi/conf.d

WORKDIR /opt/PowerDNS-Admin

RUN pip install -r /opt/PowerDNS-Admin/requirements.txt && \
    yarn install --pure-lockfile && \
    yarn add production && \
    mkdir -p /opt/PowerDNS-Admin/app/static/.webassets-cache /opt/PowerDNS-Admin/app/static/generated /opt/PowerDNS-Admin/logs && \
    mkdir -p /run/uwsgi && \
    chown -R uwsgi:uwsgi /run/uwsgi /opt/PowerDNS-Admin && \
    chmod +x /*.sh && \
    chown uwsgi:uwsgi /etc/uwsgi/conf.d/pdnsa.ini

USER uwsgi

ENV FLASK_APP=powerdnsadmin/__init__.py

EXPOSE 9191
HEALTHCHECK --interval=1m CMD /healthcheck.sh || exit 1

CMD ["/start.sh"]
