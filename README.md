[![Docker Repository on Quay](https://quay.io/repository/thwint/powerdns-admin/status "Docker Repository on Quay")](https://quay.io/repository/thwint/powerdns-admin)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)
# PowerDNS-Admin Docker image
A docker container shipping PowerDNS-Admin. See https://github.com/ngoduykhanh/PowerDNS-Admin for further information.


## Startup

### Docker
``` docker run ...```

### docker-compose
Start the container using docker-compose.
```
version: '2.1'
services:
  pdnsa:
    image: pdnsa
    container_name: pdnsa
    hostname: pdnsa
    environment:
      DB_NAME: powerdnsadmin
      DB_USER: powerdnsuser
      DB_HOST: pdnsa.db
      DB_PASSWORD: dbuserpassword
      DB_TYPE: mysql
      PORT: 9191
      ENVIRONMENT: production
    ports:
      - "9191:9191"

```

### Traefik
Start using docker-compose with traefik as reverse proxy.
```
  pdnsa:
    image: quay.io/thwint/powerdns-admin:latest
    container_name: pdnsa
    hostname: pdnsa
    environment:
      DB_NAME: powerdnsadmin
      DB_USER: powerdnsuser
      DB_HOST: pdnsa.db
      DB_PASSWORD: dbuserpassword
      DB_TYPE: mysql
      PORT: 9191
      ENVIRONMENT: production
    depends_on:
      - "pdnsa.db"
    labels:
      traefik.enable: "true"
      traefik.backend: "pdnsa"
      traefik.frontend.rule: "Host:admin.yourdomain.tld;PathPrefix:/dns"
      traefik.frontend.entryPoint: "http"
      traefik.frontend.redirect.entryPoint: "https"
      traefik.docker.network: "web"
      traefik.frontend.passHostHeader: true
      traefik.frontend.redirect.regex: /static/generated/(.*)
      traefik.frontend.redirect.replacement: https://admin.yourdomain.tld/dns/$${1}
      traefik.frontend.redirect.permanent: true

```