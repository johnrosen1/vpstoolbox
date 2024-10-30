#!/usr/bin/env bash

## Tor模组 Tor moudle

## 仅用于Trojan/Vless(grpc)代理以及.onion建站

set +e

install_tor(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Tor proxy for Vless中..." 7 68
colorEcho ${INFO} "Install Tor proxy ing"
touch /etc/apt/sources.list.d/tor.list
  cat > '/etc/apt/sources.list.d/tor.list' << EOF
deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main
EOF
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
apt-get update
apt-get install tor tor-geoipdb obfs4proxy -y
torport=$(shuf -i 23000-50000 -n 1)
  cat > '/etc/tor/torrc' << EOF
HardwareAccel 1
ClientUseIPv6 1
ClientPreferIPv6ORPort 1
#SocksListenAddress 127.0.0.1:9050
#SocksPort 9050
#SOCKSPolicy accept 127.0.0.1
#SOCKSPolicy accept6 FC00::/7
#SOCKSPolicy reject *
#ControlPort 127.0.0.1:9051
#CookieAuthentication 0
#HiddenServiceDir /var/lib/tor/hidden_service/
#HiddenServiceVersion 3
#HiddenServicePort 22 127.0.0.1:22
#HiddenServicePort 80 127.0.0.1:81
#HiddenServicePort 443 127.0.0.1:443
#Socks5Proxy 127.0.0.1:1080
#Nickname name
#DirPort auto
#ORPort auto
#ORPort [${myipv6}]:9001
#SafeLogging 0
#Log info
#IPv6Exit 1
#ExitRelay 1
#ContactInfo xxx@example.com
#BridgeRelay 1
#ServerTransportPlugin obfs4 exec /usr/bin/obfs4proxy
#ServerTransportListenAddr obfs4 0.0.0.0:${torport}
#ExtORPort auto
EOF
#torhostname=$(cat /var/lib/tor/hidden_service/hostname)
systemctl restart tor@default

# cd /etc/tor/
# mkdir snowflake
# cd /etc/tor/snowflake
#   cat > 'docker-compose.yml' << EOF
#  version: "3.8"

#  services:
#     snowflake-proxy:
#         network_mode: host
#         image: thetorproject/snowflake-proxy:latest
#         container_name: snowflake-proxy
#         restart: unless-stopped
# EOF

# docker-compose up -d
cd
}
