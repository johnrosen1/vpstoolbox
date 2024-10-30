#!/usr/bin/env bash

## RSS模组 RSS moudle

set +e

install_rss(){
cd /usr/share/nginx/

## Install Miniflux

cd /usr/share/nginx/
mkdir miniflux
cd /usr/share/nginx/miniflux
cat > "/usr/share/nginx/miniflux/docker-compose.yml" << EOF
version: '3.8'
services:
  rsshub: # 1200
    image: diygod/rsshub
    container_name: rsshub
    ports:
      - '1200:1200'
    environment:
      # PROXY_URI: 'http://127.0.0.1:8080'
      NODE_ENV: production
      CACHE_TYPE: redis
      REDIS_URL: 'redis://redis:6379/'
      PUPPETEER_WS_ENDPOINT: 'ws://browserless:3000'
    depends_on:
      - browserless
      - redis
    restart: unless-stopped
  browserless: # 3000
    image: browserless/chrome
    container_name: browserless
    restart: unless-stopped
    ports:
      - 127.0.0.1:3000:3000
  miniflux: # 8280
    image: miniflux/miniflux:latest
    restart: unless-stopped
    ports:
      - "8280:8080"
    depends_on:
      - postgresql
    environment:
      - DATABASE_URL=postgres://miniflux:adminadmin@postgresql/miniflux?sslmode=disable
      - BASE_URL=https://${domain}/miniflux/
      - RUN_MIGRATIONS=1
      - CREATE_ADMIN=1
      - ADMIN_USERNAME=admin
      - ADMIN_PASSWORD=adminadmin
  postgresql:
    image: postgres:latest
    restart: unless-stopped
    environment:
      - POSTGRES_USER=miniflux
      - POSTGRES_PASSWORD=adminadmin
    volumes:
      - miniflux-db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "miniflux"]
      interval: 10s
      start_period: 30s
volumes:
  miniflux-db:
EOF
sed -i "s/adminadmin/${password1}/g" docker-compose.yml
docker-compose up -d
cd
}

