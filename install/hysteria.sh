#!/usr/bin/env bash

## hysteria 模组

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_hysteria(){
hyver=$(curl --retry 5 -s "https://api.github.com/repos/HyNetwork/hysteria/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl --retry 5 -LO https://github.com/HyNetwork/hysteria/releases/download/${hyver}/hysteria-tun-linux-amd64
cp hysteria-tun-linux-amd64 /usr/bin/hysteria
rm hysteria-tun-linux-amd64
chmod +x /usr/bin/hysteria
mkdir /etc/hysteria
  cat > '/etc/systemd/system/hysteria.service' << EOF
[Unit]
Description=hysteria Daemon Service
Documentation=https://github.com/HyNetwork/hysteria
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/hysteria server --config /etc/hysteria/hysteria.json
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

hyport=$(shuf -i 13000-19000 -n 1)

## https://github.com/lxhao61/integrated-examples/blob/main/hysteria/TLS_config.json

  cat > '/etc/hysteria/hysteria.json' << EOF
{
  "listen": ":${hyport}",
  "protocol": "udp", //留空或"udp","wechat-video","faketcp"
  "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
  "key": "/etc/certs/${domain}_ecc/${domain}.key",
  "obfs": "${password1}",
  "up_mbps": ${target_speed_up},
  "down_mbps": ${target_speed_down},
  "alpn": "h3"
}
EOF

systemctl daemon-reload
systemctl enable hysteria.service
systemctl restart hysteria.service
}