#!/usr/bin/env bash

## Trojan模组 Trojan moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

cipher_server="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384"
cipher_client="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:DES-CBC3-SHA"

install_trojan(){
    if [[ ! -f /usr/local/bin/trojan ]]; then
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装Trojan中..." 7 68
  colorEcho ${INFO} "Install Trojan-GFW ing"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
  systemctl daemon-reload
  clear
  colorEcho ${INFO} "configuring trojan-gfw"
  setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/trojan
  fi
  cat > '/etc/systemd/system/trojan.service' << EOF
[Unit]
Description=trojan
Documentation=https://trojan-gfw.github.io/trojan/config https://trojan-gfw.github.io/trojan/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
ExecStart=/usr/local/bin/trojan /usr/local/etc/trojan/config.json
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable trojan
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${trojanport},
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "key_password": "",
        "cipher": "${cipher_server}",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": false,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "x25519",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": true,
        "fast_open": true,
        "fast_open_qlen": 512
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
if [[ ${trojanport} != 443 ]]; then
  cat > '/etc/systemd/system/trojan-web.service' << EOF
[Unit]
Description=trojan
Documentation=https://trojan-gfw.github.io/trojan/config https://trojan-gfw.github.io/trojan/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
ExecStart=/usr/local/bin/trojan /usr/local/etc/trojan/config-web.json
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable trojan
    cat > '/usr/local/etc/trojan/config-web.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "key_password": "",
        "cipher": "${cipher_server}",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": false,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "x25519",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": true,
        "fast_open": true,
        "fast_open_qlen": 512
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
systemctl daemon-reload
systemctl enable trojan-web --now
fi
chmod -R 755 /usr/local/etc/trojan/
systemctl daemon-reload
systemctl restart trojan
}

