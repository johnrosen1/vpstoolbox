#!/usr/bin/env bash

## Stun-server模组 Stun-server moudle

set +e

install_stun(){
  cd
  TERM=ansi whiptail --title "安装中" --infobox "安装stunserver中..." 7 68
  apt-get install libboost-all-dev -y
  git clone https://github.com/jselbie/stunserver
  cd stunserver
  make
  cp -f stunserver /usr/sbin
  cp -f stunclient /usr/sbin
    cat > '/etc/systemd/system/stunserver.service' << EOF
[Unit]
Description=stunserver
Documentation=https://github.com/jselbie/stunserver
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/sbin/stunserver --configfile /etc/stunserver/stun.conf --verbosity 1
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=infinity
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/stunserver
    cat > '/etc/stunserver/stun.conf' << EOF
{
    "configurations" : [

        {
           "_description" : "STUN over UDP on IPv4 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "4",
           "protocol" : "udp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over TCP on IPv4 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "4",
           "protocol" : "tcp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over UDP on IPv6 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "6",
           "protocol" : "udp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over TCP on IPv6 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "6",
           "protocol" : "tcp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        }
    ]
}
EOF
systemctl enable stunserver --now
cd
rm -rf stunserver
}