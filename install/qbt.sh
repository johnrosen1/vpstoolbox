#!/usr/bin/env bash

## Qbittorrnet-enhanced-version模组 Qbittorrnet-enhanced-version moudle

set +e

install_qbt_e(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Qbt加强版中..." 7 68
colorEcho ${INFO} "安装增强版Qbittorrent(Install Qbittorrent ing)"
apt-get install unzip -y
mkdir /root/qbt
cd /root/qbt
qbtver=$(curl --retry 5 -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl --retry 5 -LO https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/${qbtver}/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
unzip -o qb*.zip
rm qb*.zip
cp -f qb* /usr/bin/
chmod +x /usr/bin/qbittorrent-nox
chmod +x /usr/bin/qb*
cd /root
rm -rf /root/qbt
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/usr/share/nginx/
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable qbittorrent.service
mkdir /usr/share/nginx/qBittorrent/
mkdir /usr/share/nginx/qBittorrent/data/
mkdir /usr/share/nginx/qBittorrent/data/GeoIP/
cd /usr/share/nginx/qBittorrent/data/GeoIP/
curl --retry 5 -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
chmod 755 /usr/share/nginx/
chown -R nginx:nginx /usr/share/nginx/
systemctl restart qbittorrent.service

cd /usr/share/nginx/qBittorrent/
curl --retry 5 -LO https://github.com/CzBiX/qb-web/releases/download/nightly-20210808/qb-web-nightly-20210808.zip
unzip qb-web-nightly-20210808.zip
rm qb-web-nightly-20210808.zip
mv dist web
cd

sleep 5s;

cpu_thread_count=$(nproc --all)
io_thread=$((${cpu_thread_count}*4))

qbtcookie=$(curl -i --header 'Referer: http://127.0.0.1:8080' --data 'username=admin&password=adminadmin' http://127.0.0.1:8080/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
# curl http://127.0.0.1:8080/api/v2/app/version  --cookie "${qbtcookie}"
# curl http://127.0.0.1:8080/api/v2/app/preferences  --cookie "${qbtcookie}" | jq
# curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_enabled%22:false%7D  --cookie "${qbtcookie}"

## 新增下载位置
mkdir /data/
mkdir /data/torrents/
mkdir /data/media/
mkdir /data/torrents/Series/
mkdir /data/media/Series/
mkdir /data/torrents/Movies/
mkdir /data/media/Movies/
mkdir /data/torrents/Music/
mkdir /data/media/Music/
mkdir /data/torrents/Books/
mkdir /data/media/Books/
mkdir /data/torrents/XXX/
mkdir /data/media/XXX/
mkdir /data/torrents/Others/
mkdir /data/media/Others/

## 开启强制加密

curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22encryption%22:1%7D  --cookie "${qbtcookie}"

## 修改性能设置
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22auto_delete_mode%22:1%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22async_io_threads%22:${io_thread}%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22file_pool_size%22:100000%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22preallocate_all%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22customize_trackers_list_url%22:%22https:%2f%2ftrackerslist.com%2fbest.txt%22%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22auto_update_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22idn_support_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_multi_connections_from_same_ip%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22add_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22add_trackers%22:%22https:%2f%2f337hhh.xyz:443/announce%22%7D --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_tiers%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22recheck_completed_torrents%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22limit_utp_rate%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22limit_tcp_overhead%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22limit_lan_peers%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_os_cache%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_coalesce_read_write%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_embedded_tracker%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_multi_connections_from_same_ip%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_piece_extent_affinity%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22enable_upload_suggestions%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_enabled%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22web_ui_upnp%22:false%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_path%22:%22%2fusr%2fshare%2fnginx%2fqBittorrent%2fweb%2f%22%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22max_connec%22:-1%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22max_connec_per_torrent%22:-1%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22web_ui_address%22:%22127.0.0.1%22%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22validate_https_tracker_certificate%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22peer_tos%22:0%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22block_peers_on_privileged_ports%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22ssrf_mitigation%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22disk_cache_ttl%22:15%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22checking_memory_use%22:256%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22disk_cache%22:-1%7D  --cookie "${qbtcookie}"
## 设置自动管理以及默认下载位置
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22auto_tmm_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22save_path%22:%22%2fdata%2ftorrents%2f%22%7D --cookie "${qbtcookie}"

## IP动态更新
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22announce_ip%22:%22${myip}%22%7D --cookie "${qbtcookie}"

## 新增分类
curl -X POST -F 'category=Series' -F 'savePath=/data/torrents/Series/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
curl -X POST -F 'category=Movies' -F 'savePath=/data/torrents/Movies/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
curl -X POST -F 'category=Music' -F 'savePath=/data/torrents/Music/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
curl -X POST -F 'category=Bookes' -F 'savePath=/data/torrents/Books/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
curl -X POST -F 'category=XXX' -F 'savePath=/data/torrents/XXX/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
curl -X POST -F 'category=Others' -F 'savePath=/data/torrents/Others/' http://127.0.0.1:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
## 新增标签
curl -X POST -F 'tags=BT,PT' -F 'savePath=/data/torrents/XXX/' http://127.0.0.1:8080/api/v2/torrents/createTags --cookie "${qbtcookie}"
## 修改密码，锁定配置
curl http://127.0.0.1:8080/api/v2/app/setPreferences?json=%7B%22web_ui_password%22:%22${password1}%22%7D  --cookie "${qbtcookie}"
}
