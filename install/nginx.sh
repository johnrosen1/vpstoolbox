#!/usr/bin/env bash

## NGINX模组 NGINX moudle

set +e

install_nginx(){
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装NGINX中..." 7 68
  colorEcho ${INFO} "Install Nginx ing"
  apt --fix-broken install -y
  apt-get install ca-certificates lsb-release -y
  apt-get install gnupg gnupg2 -y
  touch /etc/apt/sources.list.d/nginx.list
  if [[ ${dist} == ubuntu ]]; then
echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx"  | sudo tee /etc/apt/sources.list.d/nginx.list
else
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
fi
  curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
  #apt-key fingerprint ABF5BD827BD9BF62
  apt-get update
  sh -c 'echo "y\n\ny\ny\ny\n" | apt-get install nginx -y'
  id -u nginx
if [[ $? != 0 ]]; then
useradd -r nginx --shell=/usr/sbin/nologin
apt-get install nginx -y
fi
  cat > '/lib/systemd/system/nginx.service' << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
Before=netdata.service trojan.service
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nginx
mkdir /usr/share/nginx/cache
#mkdir /usr/share/nginx/php_cache
  cat > '/etc/nginx/nginx.conf' << EOF
user root;
worker_processes auto;

error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
  worker_connections 100000;
  use epoll;
  multi_accept on;
}

http {

  #proxy_cache_path /usr/share/nginx/cache levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m use_temp_path=off;
  #proxy_cache_valid 200 302 10m;
  #proxy_cache_valid 404      1m;
  #proxy_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  #proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
  #proxy_cache_revalidate on;
  #proxy_cache_background_update on;
  #proxy_cache_lock on;
  #proxy_cache my_cache;

  #fastcgi_cache_path /usr/share/nginx/php_cache levels=1:2 keys_zone=phpcache:10m max_size=100m inactive=60m use_temp_path=off;
  #fastcgi_cache_valid 200 302 10m;
  #fastcgi_cache_valid 404      1m;
  #fastcgi_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  #fastcgi_cache_use_stale error timeout updating invalid_header http_500 http_503;
  #fastcgi_cache_revalidate on;
  #fastcgi_cache_background_update on;
  #fastcgi_cache_lock on;
  #fastcgi_cache phpcache;
  #fastcgi_cache_key "\$scheme\$proxy_host\$request_uri";

  autoindex_exact_size off;
  http2_push_preload on;
  aio threads;
  aio_write on;
  charset UTF-8;
  tcp_nodelay on;
  tcp_nopush on;
  server_tokens off;
  
  proxy_intercept_errors off;
  proxy_http_version 1.1;
  proxy_ssl_protocols TLSv1.2 TLSv1.3;
  proxy_set_header Host \$http_host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_socket_keepalive on;
  proxy_max_temp_file_size 0;

  set_real_ip_from 103.21.244.0/22;
  set_real_ip_from 103.22.200.0/22;
  set_real_ip_from 103.31.4.0/22;
  set_real_ip_from 104.16.0.0/13;
  set_real_ip_from 104.24.0.0/14;
  set_real_ip_from 108.162.192.0/18;
  set_real_ip_from 131.0.72.0/22;
  set_real_ip_from 141.101.64.0/18;
  set_real_ip_from 162.158.0.0/15;
  set_real_ip_from 172.64.0.0/13;
  set_real_ip_from 173.245.48.0/20;
  set_real_ip_from 188.114.96.0/20;
  set_real_ip_from 190.93.240.0/20;
  set_real_ip_from 197.234.240.0/22;
  set_real_ip_from 198.41.128.0/17;
  set_real_ip_from 2400:cb00::/32;
  set_real_ip_from 2606:4700::/32;
  set_real_ip_from 2803:f800::/32;
  set_real_ip_from 2405:b500::/32;
  set_real_ip_from 2405:8100::/32;
  set_real_ip_from 2c0f:f248::/32;
  set_real_ip_from 2a06:98c0::/29;
  set_real_ip_from 127.0.0.1;

  real_ip_header CF-Connecting-IP;
  #real_ip_header X-Forwarded-For; 
  real_ip_recursive on;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_cf_connecting_ip" "\$http_x_forwarded_for" "\$gzip_ratio"';

  access_log /var/log/nginx/access.log main;

  sendfile on;
  gzip on;
  gzip_proxied any;
  gzip_types
    application/javascript
    application/x-javascript
    text/javascript
    text/css
    text/xml
    application/xhtml+xml
    application/xml
    application/atom+xml
    application/rdf+xml
    application/rss+xml
    application/geo+json
    application/json
    application/ld+json
    application/manifest+json
    application/x-web-app-manifest+json
    image/svg+xml
    text/x-cross-domain-policy;
  gzip_comp_level 1;
  gzip_vary on;
  gzip_static on;
  gzip_disable "MSIE [1-6]\.";  

  include /etc/nginx/conf.d/default.conf;
  include /etc/nginx/conf.d/verify.conf;
}
EOF
clear
touch /etc/nginx/conf.d/verify.conf
touch /etc/nginx/conf.d/default.conf
systemctl restart nginx
}
