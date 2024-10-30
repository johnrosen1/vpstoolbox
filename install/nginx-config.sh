#!/usr/bin/env bash

## Nginx config模组 Nginx moudle

## Standalone用法

# install_jellyfin=1

# nginx_config

set +e

cipher_server="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"

nginx_config(){
  clear
TERM=ansi whiptail --title "安装中" --infobox "配置NGINX中..." 7 68
  colorEcho ${INFO} "配置(configing) nginx"
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
touch /etc/nginx/conf.d/verify.conf
touch /etc/nginx/conf.d/default.conf
  cat > '/etc/nginx/conf.d/default.conf' << EOF
server {
  listen 127.0.0.1:81 fastopen=512 default_server so_keepalive=on;
  listen 127.0.0.1:82 http2 fastopen=512 default_server so_keepalive=on;
  server_name $domain _;
  # listen 443 ssl http2 fastopen=512 reuseport default_server so_keepalive=on;
  # listen [::]:443 ssl http2 fastopen=512 reuseport default_server so_keepalive=on;
  # ssl_certificate     /etc/certs/${domain}_ecc/fullchain.cer;
  # ssl_certificate_key /etc/certs/${domain}_ecc/${domain}.key;
  # ssl_client_certificate /etc/certs/${domain}_ecc/ca.cer;
  # ssl_protocols TLSv1.3 TLSv1.2;
  # ssl_prefer_server_ciphers on;
  # ssl_ciphers TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:$cipher_server;
  # ssl_reject_handshake off;
  # ssl_conf_command Ciphersuites TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384;
  # ssl_early_data on;
  # proxy_set_header Early-Data \$ssl_early_data;
  # ssl_verify_client off;
  # ssl_ocsp          on;
  # ssl_stapling on;
  # ssl_stapling_verify on;
  # resolver               1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 valid=60s;
  # ssl_session_tickets off;
  # ssl_session_cache shared:SSL:10m;
  resolver_timeout 10s;
  client_header_timeout 60m;
  #if (\$http_user_agent ~* (360|Tencent|MicroMessenger|Maxthon|TheWorld|UC|OPPO|baidu|Sogou|2345|) ) { return 403; }
  #if (\$http_user_agent ~* (wget|curl) ) { return 403; }
  #if (\$http_user_agent = "") { return 403; }
  #if (\$host != "$domain") { return 404; }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  #add_header X-Cache-Status \$upstream_cache_status;
    location /.well-known/acme-challenge/ { ## Acme.sh 证书签发及续签专用
      root /usr/share/nginx/;
    }
EOF

if [[ $install_hexo == 1 ]]; then
echo "  location / {" >> /etc/nginx/conf.d/default.conf
echo "    #proxy_pass http://127.0.0.1:4000/; # Hexo server" >> /etc/nginx/conf.d/default.conf
echo "    root /usr/share/nginx/hexo/public/; # Hexo public content" >> /etc/nginx/conf.d/default.conf
echo "    #error_page 404  /404.html;" >> /etc/nginx/conf.d/default.conf
echo "  }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_alist == 1 ]]; then
echo "  location / {" >> /etc/nginx/conf.d/default.conf
echo "    #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "    proxy_set_header X-Forwarded-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "    proxy_pass http://127.0.0.1:5244/;" >> /etc/nginx/conf.d/default.conf
echo "  }" >> /etc/nginx/conf.d/default.conf
fi

if [[ $install_nextcloud == 1 ]]; then
echo "    include /etc/nginx/conf.d/nextcloud.conf;" >> /etc/nginx/conf.d/default.conf
touch /etc/nginx/conf.d/nextcloud.conf
cat << EOF > /etc/nginx/conf.d/nextcloud.conf

# https://docs.nextcloud.com/server/23/admin_manual/installation/nginx.html

    location = /.well-known/carddav { return 301 https://${domain}:443/nextcloud/remote.php/dav/; }
    location = /.well-known/caldav { return 301 https://${domain}:443/nextcloud/remote.php/dav/; }
    location = /.well-known/webfinger { return 301 https://${domain}:443/nextcloud/index.php/.well-known/webfinger; }
    location = /.well-known/nodeinfo { return 301 https://${domain}:443/nextcloud/index.php/.well-known/nodeinfo; }

    location ^~ /nextcloud/ {
        root /usr/share/nginx/;
        client_body_temp_path /usr/share/nginx/tmp/ 1 2;
        client_max_body_size 0;
        fastcgi_buffers 64 4K;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;
        add_header Referrer-Policy                      "no-referrer"   always;
        add_header X-Content-Type-Options               "nosniff"       always;
        add_header X-Download-Options                   "noopen"        always;
        add_header X-Frame-Options                      "SAMEORIGIN"    always;
        add_header X-Permitted-Cross-Domain-Policies    "none"          always;
        add_header X-Robots-Tag                         "none"          always;
        add_header X-XSS-Protection                     "1; mode=block" always;
        #fastcgi_hide_header X-Powered-By;
        index index.php index.html /nextcloud/index.php\$request_uri;

        expires 1m;

        location = /nextcloud/ {
            if ( \$http_user_agent ~ ^DavClnt ) {
                return 302 /nextcloud/remote.php/webdav/\$is_args\$args;
            }
        }

        location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)(?:\$|/)    { return 404; }
        location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

        location ~ \.php(?:\$|/) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
            set \$path_info \$fastcgi_path_info;

            try_files \$fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            fastcgi_param PATH_INFO \$path_info;
            fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass unix:/run/php/php8.1-fpm.sock;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
            fastcgi_read_timeout 600s;
        }

        location ~ \.(?:css|js|svg|gif)\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 6M;
            access_log off;
        }

        location ~ \.woff2?\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 7d;
            access_log off;
        }

        location /nextcloud/ {
            try_files \$uri \$uri/ /nextcloud/index.php\$request_uri;
        }
    }
EOF
fi
if [[ $install_grpc == 1 ]]; then
echo "    include /etc/nginx/conf.d/grpc.conf;" >> /etc/nginx/conf.d/default.conf
touch /etc/nginx/conf.d/grpc.conf
cat << EOF > /etc/nginx/conf.d/grpc.conf
	location /${path_new} {
    client_max_body_size 0;
    client_body_buffer_size 1m;
    client_body_timeout 12h;
    keepalive_disable none;
    keepalive_time 12h;
    keepalive_timeout 12h;
    keepalive_requests 10000;
    grpc_socket_keepalive on;
    grpc_read_timeout 12h;
    grpc_send_timeout 12h;
    grpc_pass unix:/dev/shm/vgrpc.sock;
    grpc_set_header X-Real-IP \$remote_addr;
    etag off;
    lingering_close always;
    lingering_time 12h;
    lingering_timeout 1s;
    proxy_buffering off;
	}
EOF
fi
if [[ $install_typecho == 1 ]]; then
echo "    #location / {" >> /etc/nginx/conf.d/default.conf
echo "    #    client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "    #    index index.php index.html;" >> /etc/nginx/conf.d/default.conf
echo "    #    root /usr/share/nginx/typecho/;" >> /etc/nginx/conf.d/default.conf
echo "    #    location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "    #    include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_pass unix:/run/php/php8.1-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "    #    }" >> /etc/nginx/conf.d/default.conf
echo "    #    }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_jellyfin == 1 ]]; then
echo "    location /emby {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/emby/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /emby/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8096/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## sonarr 8989
echo "    location /sonarr {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/sonarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /sonarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8989/sonarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## radarr 7878
echo "    location /radarr {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/radarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /radarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:7878/radarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## lidarr 8686
echo "    location /lidarr {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/lidarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /lidarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8686/lidarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## readarr 8787
echo "    location /readarr {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/readarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /readarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8787/readarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## bazarr 6767
echo "    location /bazarr {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/bazarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /bazarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6767/bazarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## chinesesubfinder 19035
echo "    location /chinesesubfinder {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/chinesesubfinder/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /chinesesubfinder/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:19035/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## prowlarr 9696
echo "    location /prowlarr{" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/prowlarr/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /prowlarr/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:9696/prowlarr/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## jackett 9117
echo "    location /jackett {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/jackett/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /jackett/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:9117/jackett/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## ombi 3579
echo "    location /ombi {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/ombi/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /ombi/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3579/ombi/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
## nzbget 6789
echo "    location /nzbget {" >> /etc/nginx/conf.d/default.conf
echo "        return 302 https://${domain}:443/nzbget/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location /nzbget/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6789/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rocketchat == 1 ]]; then
echo "    location /chat/ {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_no_cache 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache_bypass 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Nginx-Proxy true;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/chat/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /file-upload/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/chat/file-upload/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /avatar/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/chat/avatar/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /assets/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/chat/assets/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /home {" >> /etc/nginx/conf.d/default.conf
echo "        return 301 https://${domain}/chat/home/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_mail == 1 ]]; then
echo "    location /mail/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/roundcubemail/;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php8.1-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_speedtest == 1 ]]; then
echo "    location /${password1}_speedtest/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/speedtest/;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/speedtest.js;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/favicon.ico;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass   unix:/run/php/php8.1-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rss == 1 ]] || [[ $install_jellyfin == 1 ]]; then
echo "    location /rsshub/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:1200/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rss == 1 ]]; then
echo "    location /miniflux/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host ${domain};" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8280/miniflux/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_aria == 1 ]]; then
echo "    location $ariapath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6800/jsonrpc;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ariang/ {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.html;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/ariang/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_qbt_e == 1 ]] || [[ $install_qbt_o == 1 ]]; then
echo "    location /qbt/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass              http://127.0.0.1:8080/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header        X-Forwarded-Host        \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_filebrowser == 1 ]]; then
echo "    location /file/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8081/;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_netdata == 1 ]]; then
echo "    location ~ /${password1}_netdata/(?<ndpath>.*) {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Server \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo '        proxy_set_header Connection "keep-alive";' >> /etc/nginx/conf.d/default.conf
echo "        proxy_store off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://netdata/\$ndpath\$is_args\$args;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
echo "    location ~ ^/announce$ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_comp_level 6;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/scrape$ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_comp_level 6;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "" >> /etc/nginx/conf.d/default.conf
if [[ ${ipissue} == 1 ]]; then
echo good
else
echo "server {" >> /etc/nginx/conf.d/default.conf
echo "    listen 80 fastopen=512 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    listen [::]:80 fastopen=512 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    location /.well-known/acme-challenge/ {" >> /etc/nginx/conf.d/default.conf
echo "      root /usr/share/nginx/;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location / {" >> /etc/nginx/conf.d/default.conf
echo "    return 301 https://\$host\$request_uri;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_netdata == 1 ]]; then
echo "server { #For Netdata only !" >> /etc/nginx/conf.d/default.conf
echo "    listen 127.0.0.1:83 fastopen=512;" >> /etc/nginx/conf.d/default.conf
echo "    location /stub_status {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    stub_status;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/(status|ping)\$ {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    allow 127.0.0.1;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "    include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_pass   unix:/run/php/php8.1-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "upstream netdata {" >> /etc/nginx/conf.d/default.conf
echo "    server 127.0.0.1:19999;" >> /etc/nginx/conf.d/default.conf
echo "    keepalive 64;" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
fi
chown -R nginx:nginx /usr/share/nginx/
systemctl restart nginx
}
