#!/usr/bin/env bash

## Aria2模组 Aria2 moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_aria2(){
TERM=ansi whiptail --title "安装中" --infobox "安装Aria2中..." 7 68
cd /root/
trackers_list=$(wget --no-check-certificate -qO- https://trackerslist.com/best_aria2.txt)
ariaport=$(shuf -i 13000-19000 -n 1)
mkdir /etc/aria2/
ariaver1=$(curl -s "https://api.github.com/repos/aria2/aria2/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ariaver2=$(curl -s "https://api.github.com/repos/aria2/aria2/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c9-20)
apt-get install build-essential nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev libssl-dev libuv1-dev -q -y
curl --retry 5 -LO --progress-bar https://github.com/aria2/aria2/releases/download/${ariaver1}/aria2-${ariaver2}.tar.xz
tar -xvf aria2*.xz
rm *.xz
cd /root/aria2*
sed -i 's/"1", 1, 16/"128", 1, -1/g' /root/aria2*/src/OptionHandlerFactory.cc
sed -i 's/"20M", 1_m, 1_g/"4K", 1_k, 1_g/g' /root/aria2*/src/OptionHandlerFactory.cc
sed -i 's/PREF_CONNECT_TIMEOUT, TEXT_CONNECT_TIMEOUT, "60", 1, 600/PREF_CONNECT_TIMEOUT, TEXT_CONNECT_TIMEOUT, "30", 1, 600/g' /root/aria2*/src/OptionHandlerFactory.cc
sed -i 's/PREF_PIECE_LENGTH, TEXT_PIECE_LENGTH, "1M", 1_m, 1_g/PREF_PIECE_LENGTH, TEXT_PIECE_LENGTH, "4k", 1_k, 1_g/g' /root/aria2*/src/OptionHandlerFactory.cc
sed -i 's/new NumberOptionHandler(PREF_RETRY_WAIT, TEXT_RETRY_WAIT, "0", 0, 600/new NumberOptionHandler(PREF_RETRY_WAIT, TEXT_RETRY_WAIT, "2", 0, 600/g' /root/aria2*/src/OptionHandlerFactory.cc
sed -i 's/new NumberOptionHandler(PREF_SPLIT, TEXT_SPLIT, "5", 1, -1,/new NumberOptionHandler(PREF_SPLIT, TEXT_SPLIT, "8", 1, -1,/g' /root/aria2*/src/OptionHandlerFactory.cc
/root/aria2*/configure --disable-bittorrent
make -j $(nproc --all)
make install
chmod +x /usr/local/bin/aria2c
rm -rf /root/aria2*
apt-get autoremove -y

  cat > '/etc/systemd/system/aria2.service' << EOF
[Unit]
Description=Aria2c download manager
Documentation=https://aria2.github.io/manual/en/html/index.html
Requires=network.target
After=network.target

[Service]
Type=forking
User=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/aria2c --conf-path=/etc/aria2/aria2.conf
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
  cat > '/etc/aria2/aria2.conf' << EOF
user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36
#Upload Settings###
#on-download-complete=/etc/aria2/autoupload.sh
#Global Settings###
daemon=true
async-dns=true
optimize-concurrent-downloads=true
log-level=warn
console-log-level=info
human-readable=true
log=/var/log/aria2.log
rlimit-nofile=51200
event-poll=epoll
min-tls-version=TLSv1.2
dir=/usr/share/nginx/aria2/
file-allocation=falloc
check-integrity=true
conditional-get=false
disk-cache=64M #Larger is better,but should be smaller than available RAM !
enable-color=true
continue=true
always-resume=true
max-concurrent-downloads=50
content-disposition-default-utf8=true
#split=16
##Http(s) Settings#######
enable-http-keep-alive=true
enable-http-pipelining=true
http-accept-gzip=true
http-auth-challenge=true
http-no-cache=true
min-split-size=10M
max-connection-per-server=128
lowest-speed-limit=0
disable-ipv6=false
max-tries=0
#retry-wait=0
input-file=/usr/local/bin/aria2.session
save-session=/usr/local/bin/aria2.session
save-session-interval=60
force-save=true
metalink-preferred-protocol=https
##Rpc Settings############
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=false
rpc-secure=false
rpc-listen-port=6800
rpc-secret=$ariapasswd
#Bittorrent Settings######
follow-torrent=true
listen-port=$ariaport
enable-dht=true
enable-dht6=true
enable-peer-exchange=true
seed-ratio=0
bt-enable-lpd=true
bt-hash-check-seed=true
bt-seed-unverified=false
bt-save-metadata=true
bt-load-saved-metadata=true
bt-require-crypto=true
bt-force-encryption=true
bt-min-crypto-level=arc4
bt-max-open-files=1000000
bt-max-peers=0
bt-tracker=$trackers_list
EOF
clear
touch /var/log/aria2.log
touch /usr/local/bin/aria2.session
mkdir /usr/share/nginx/aria2/
chmod 755 /usr/share/nginx/aria2/
systemctl daemon-reload
systemctl enable aria2 --now
cd
## 安装 AriaNG
if [[ ! -d /usr/share/nginx/ariang ]]; then
  mkdir /usr/share/nginx/ariang
fi
cd /usr/share/nginx/ariang
ariangver=$(curl -s "https://api.github.com/repos/mayswind/AriaNg/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl --retry 5 -LO https://github.com/mayswind/AriaNg/releases/download/${ariangver}/AriaNg-${ariangver}.zip
unzip *.zip
rm -rf *.zip
cd
TERM=ansi whiptail --title "安装中" --infobox "拉取全自动Aria2上传脚本中..." 7 68
cd /etc/aria2/
curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/autoupload.sh
chmod +x /etc/aria2/autoupload.sh
}