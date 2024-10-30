#!/usr/bin/env bash

## Netdata模组 Netdata moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_netdata(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Netdata中..." 7 68
colorEcho ${INFO} "Install netdata ing"
bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --dont-wait --static-only --disable-telemetry
sed -i "s/SEND_EMAIL=\"YES\"/SEND_EMAIL=\"NO\"/" /opt/netdata/usr/lib/netdata/conf.d/health_alarm_notify.conf
sed -i "s/Restart=on-failure/Restart=always/" /lib/systemd/system/netdata.service
systemctl daemon-reload
systemctl stop netdata
killall netdata
  cat > '/opt/netdata/etc/netdata/python.d/nginx.conf' << EOF
localhost:

localipv4:
  name : 'local'
  url  : 'http://127.0.0.1:83/stub_status'
EOF
if [[ ${install_php} == 1 ]]; then
cat > '/opt/netdata/etc/netdata/python.d/phpfpm.conf' << EOF
local:
  url     : 'http://127.0.0.1:83/status?full&json'
EOF
fi
cat > '/opt/netdata/etc/netdata/python.d/mysql.conf' << EOF
update_every : 10
priority     : 90100

local:
  user     : 'netdata'
  update_every : 1
EOF
  cat > '/opt/netdata/etc/netdata/go.d/docker_engine.conf' << EOF
jobs:
  - name: local
    url : http://127.0.0.1:9323/metrics
EOF
systemctl enable netdata
systemctl restart netdata
clear
}


