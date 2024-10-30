#!/usr/bin/env bash

## opentracker模组 opentracker moudle

set +e

install_tracker(){
  TERM=ansi whiptail --title "安装中" --infobox "安装Bittorrent-tracker中" 7 68
colorEcho ${INFO} "Install Bittorrent-tracker ing"
apt-get install libowfat-dev make git build-essential zlib1g-dev libowfat-dev make git -y
useradd -r opentracker --shell=/usr/sbin/nologin
git clone git://erdgeist.org/opentracker opentracker
cd opentracker
#sed -i 's/#FEATURES+=-DWANT_V6/FEATURES+=-DWANT_V6/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_QUERY_STRING/FEATURES+=-DWANT_IP_FROM_QUERY_STRING/' Makefile
sed -i 's/#FEATURES+=-DWANT_COMPRESSION_GZIP/FEATURES+=-DWANT_COMPRESSION_GZIP/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_PROXY/FEATURES+=-DWANT_IP_FROM_PROXY/' Makefile
sed -i 's/#FEATURES+=-DWANT_LOG_NUMWANT/FEATURES+=-DWANT_LOG_NUMWANT/' Makefile
sed -i 's/#FEATURES+=-DWANT_SYSLOGS/FEATURES+=-DWANT_SYSLOGS/' Makefile
sed -i 's/#FEATURES+=-DWANT_FULLLOG_NETWORKS/FEATURES+=-DWANT_FULLLOG_NETWORKS/' Makefile
#sed -i 's/#FEATURES+=-DWANT_SYNC_LIVE/FEATURES+=-DWANT_SYNC_LIVE/' Makefile
make
cp -f opentracker /usr/sbin/opentracker
  cat > '/etc/systemd/system/tracker.service' << EOF
[Unit]
Description=Bittorrent-Tracker Daemon Service
Documentation=https://erdgeist.org/arts/software/opentracker/
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=opentracker
Group=opentracker
RemainAfterExit=yes
ExecStart=/usr/sbin/opentracker -d /etc/opentracker
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/opentracker
systemctl daemon-reload
systemctl enable tracker --now
cd
rm -rf opentracker
curl -X POST "https://newtrackon.com/api/add" \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d new_trackers=udp%3A%2F%2F${domain}%3A6969%2Fannounce
}