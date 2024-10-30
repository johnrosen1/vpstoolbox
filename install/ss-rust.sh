#!/usr/bin/env bash

## SS rust模组 SS rust moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

ss_version=$(curl -s "https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

install_ss_rust(){
	curl --retry 5 -LO https://github.com/shadowsocks/shadowsocks-rust/releases/download/${ss_version}/shadowsocks-${ss_version}.x86_64-unknown-linux-gnu.tar.xz
	tar -xvf shadowsocks*
	cp -f ssserver /usr/sbin
	mkdir /etc/ss-rust
  rm -rf *.xz
  rm -rf ss*
  openssl rand -base64 16
  	cat > '/etc/ss-rust/config.json' << EOF
{
    "server": "::",
    "mode": "tcp_and_udp",
    "server_port": 8388,
    "password": "${password1}",
    "timeout": 300,
    "method": "2022-blake3-aes-128-gcm"
}
EOF
  cat > '/etc/systemd/system/ssserver.service' << EOF
[Unit]
Description=shadowsocks-rust
Documentation=https://github.com/shadowsocks/shadowsocks-rust
After=network.target

[Service]
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/sbin/ssserver -c /etc/ss-rust/config.json
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable ssserver
systemctl restart ssserver
}
