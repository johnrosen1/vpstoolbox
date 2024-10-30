#!/usr/bin/env bash

## Emby模组 Emby moudle

set +e

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

install_emby(){
apt install -y apt-transport-https
curl --retry 5 -LO https://github.com/MediaBrowser/Emby.Releases/releases/download/4.7.1.0/emby-server-deb_4.7.1.0_amd64.deb
dpkg -i emby-server*.deb
rm emby-server*.deb
systemctl stop emby-server
sed -i "s/User=emby/User=root/g" /lib/systemd/system/emby-server.service
systemctl daemon-reload
cd /root
systemctl restart emby-server
}