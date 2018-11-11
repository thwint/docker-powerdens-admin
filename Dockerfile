FROM quay.io/thwint/alpine-base:3.8-0

LABEL maintainer="Tom Winterhalder <tom.winterhalder@gmail.com>"
ARG PDNS_ADMIN_VERSION=0.1
ENV PDNS_ADMIN_VERSION=${PDNS_ADMIN_VERSION}
ENV FLASK_APP=/app/app/__init__.py

WORKDIR /app/

ADD https://github.com/ngoduykhanh/PowerDNS-Admin/archive/v${PDNS_ADMIN_VERSION}.tar.gz /app/
COPY start.sh /

RUN apk add --no-cache \
    python3 python3-dev \
    nodejs yarn build-base pkgconfig \
    libffi-dev openldap-dev \
    mariadb-dev postgresql-dev xmlsec-dev libxslt-dev && \
    python3 -m ensurepip && \
    pip3 install -U pip setuptools && \
    rm -rf /var/cache/apk/* && \
    tar -xzf v${PDNS_ADMIN_VERSION}.tar.gz -C /app --strip-components=1&& \
    rm v${PDNS_ADMIN_VERSION}.tar.gz && \
    pip install -r /app/requirements.txt && \
    yarn install --pure-lockfile  && \
    mkdir -p /app/app/static/.webassets-cache /app/app/static/generated && \
    chown -R baseuser:basegroup /app/app/static/generated && \
    chown -R baseuser:basegroup /app/app/static/custom && \
    chown -R baseuser:basegroup /app/app/static/.webassets-cache && \
    chmod +x /start.sh

COPY config.py /app/

USER baseuser

EXPOSE 9191
#HEALTHCHECK --interval=1m CMD /healthcheck.sh || exit 1

CMD ["/start.sh"]
