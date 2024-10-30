#!/usr/bin/env bash

## Filebrowser模组 Filebrowser moudle

set +e

install_filebrowser(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Filebrowser中..." 7 68
colorEcho ${INFO} "Install Filebrowser ing"

filever=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep -o '"tag_name": ".*"' | sed 's/"//g' | sed 's/tag_name: //g')

curl --retry 5 -LO https://github.com/filebrowser/filebrowser/releases/download/${filever}/linux-amd64-filebrowser.tar.gz
tar -xvf linux-amd64-filebrowser.tar.gz
cp -f filebrowser /usr/local/bin/filebrowser
rm linux-amd64-filebrowser.tar.gz
rm CHANGELOG.md LICENSE README.md filebrowser

  cat > '/etc/systemd/system/filebrowser.service' << EOF
[Unit]
Description=filebrowser browser
Documentation=https://github.com/filebrowser/filebrowser
After=network.target

[Service]
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/filebrowser -r / -d /etc/filebrowser/database.db -b /file/ -p 8081
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/filebrowser/
systemctl daemon-reload
systemctl enable filebrowser --now
chmod -R 755 /etc/filebrowser/
cd
}
