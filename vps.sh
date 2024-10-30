#!/usr/bin/env bash
# VPSTOOLBOX

# 一键安装Trojan-GFW代理,Hexo博客,Nextcloud等應用程式.
# One click install Trojan-gfw Hexo Nextcloud and so on.

# MIT License
#
# Copyright (c) 2019-2022 JohnRosen

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#如果你在使用VPSToolBox时遇到任何问题,请仔细阅读README.md/code或者**通过 [Telegram](https://t.me/vpstoolbox_chat)请求支援** !                                  

clear

set +e

## Predefined env
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1

#System Requirement
if [[ $(id -u) != 0 ]]; then
  echo -e "请使用root或者sudo用户运行,Please run this script as root or sudoer."
  exit 1
fi

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###Legacy Defined Colors
ERROR="31m"      # Error message
SUCCESS="32m"    # Success message
WARNING="33m"   # Warning message
INFO="36m"     # Info message
LINK="92m"     # Share Link Message

#Predefined install,do not change!!!
install_bbr=1
install_nodejs=1
install_trojan=1
trojanport="443"
tcp_fastopen="true"

#Disable cloud-init
rm -rf /lib/systemd/system/cloud*

colorEcho(){
  COLOR=$1
  echo -e "\033[${COLOR}${@:2}\033[0m"
}

#设置系统语言
setlanguage(){
  mkdir /root/.trojan/
  mkdir /etc/certs/
  chattr -i /etc/locale.gen
  cat > '/etc/locale.gen' << EOF
C.UTF-8 UTF-8
#zh_CN.UTF-8 UTF-8
#zh_TW.UTF-8 UTF-8
#en_US.UTF-8 UTF-8
#ja_JP.UTF-8 UTF-8
EOF
locale-gen
update-locale
chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="C.UTF-8"
LANG="C.UTF-8"
LC_ALL="C.UTF-8"
EOF
export LANGUAGE="C.UTF-8"
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
}

## 写入配置文件
prasejson(){
  cat > '/root/.trojan/config.json' << EOF
{
  "installed": "1",
  "trojanport": "${trojanport}",
  "domain": "$domain",
  "password1": "$password1",
  "password2": "$password2",
  "qbtpath": "$qbtpath",
  "trackerpath": "$trackerpath",
  "trackerstatuspath": "$trackerstatuspath",
  "ariapath": "$ariapath",
  "ariapasswd": "$ariapasswd",
  "filepath": "$filepath",
  "check_trojan": "$check_trojan",
  "check_dns": "$check_dns",
  "check_rss": "$check_rss",
  "check_qbt": "$check_qbt",
  "check_aria": "$check_aria",
  "check_file": "$check_file",
  "check_speed": "$check_speed",
  "check_mariadb": "$check_mariadb",
  "check_mail": "$check_mail",
  "check_qbt_origin": "$check_qbt_origin",
  "check_tracker": "$check_tracker",
  "check_cloud": "$check_cloud",
  "check_tor": "$check_tor",
  "check_ss": "$check_ss",
  "check_echo": "$check_echo",
  "check_rclone": "$check_rclone",
  "check_ip": "$check_ip",
  "check_hy": "$check_hy",
  "zerossl_api": "$zerossl_api",
  "fastopen": "${fastopen}"
}
EOF
}

## 读取配置文件
readconfig(){
  domain="$( jq -r '.domain' "/root/.trojan/config.json" )"
  trojanport="$( jq -r '.trojanport' "/root/.trojan/config.json" )"
  password2="$( jq -r '.password2' "/root/.trojan/config.json" )"
  password1="$( jq -r '.password1' "/root/.trojan/config.json" )"
  qbtpath="$( jq -r '.qbtpath' "/root/.trojan/config.json" )"
  trackerpath="$( jq -r '.trackerpath' "/root/.trojan/config.json" )"
  trackerstatuspath="$( jq -r '.username' "/root/.trojan/config.json" )"
  ariapath="$( jq -r '.ariapath' "/root/.trojan/config.json" )"
  ariapasswd="$( jq -r '.ariapasswd' "/root/.trojan/config.json" )"
  filepath="$( jq -r '.filepath' "/root/.trojan/config.json" )"
  check_trojan="$( jq -r '.check_trojan' "/root/.trojan/config.json" )"
  check_dns="$( jq -r '.check_dns' "/root/.trojan/config.json" )"
  check_rss="$( jq -r '.check_rss' "/root/.trojan/config.json" )"
  check_qbt="$( jq -r '.check_qbt' "/root/.trojan/config.json" )"
  check_aria="$( jq -r '.check_aria' "/root/.trojan/config.json" )"
  check_file="$( jq -r '.check_file' "/root/.trojan/config.json" )"
  check_speed="$( jq -r '.check_speed' "/root/.trojan/config.json" )"
  check_mariadb="$( jq -r '.check_mariadb' "/root/.trojan/config.json" )"
  check_mail="$( jq -r '.check_mail' "/root/.trojan/config.json" )"
  check_qbt_origin="$( jq -r '.check_qbt_origin' "/root/.trojan/config.json" )"
  check_tracker="$( jq -r '.check_tracker' "/root/.trojan/config.json" )"
  check_cloud="$( jq -r '.check_cloud' "/root/.trojan/config.json" )"
  check_tor="$( jq -r '.check_tor' "/root/.trojan/config.json" )"
  check_chat="$( jq -r '.check_chat' "/root/.trojan/config.json" )"
  check_ss="$( jq -r '.check_ss' "/root/.trojan/config.json" )"
  check_echo="$( jq -r '.check_echo' "/root/.trojan/config.json" )"
  check_rclone="$( jq -r '.check_rclone' "/root/.trojan/config.json" )"
  check_ip="$( jq -r '.check_ip' "/root/.trojan/config.json" )"
  check_hy="$( jq -r '.check_hy' "/root/.trojan/config.json" )"
  zerossl_api="$( jq -r '.zerossl_api' "/root/.trojan/config.json" )"
  fastopen="$( jq -r '.fastopen' "/root/.trojan/config.json" )"
}

## 清理apt以及模块化的.sh文件等
clean_env(){
prasejson
cd /root
if [[ -n ${uuid_new} ]]; then
echo "vless://${uuid_new}@${myip}:${trojanport}?mode=gun&security=tls&type=grpc&serviceName=${path_new}&sni=${domain}#Vless(${route_final} ${mycountry} ${myip_org} ${myip} ${myipv6} ${target_speed_up} Mbps)" &> ${myip}.txt
echo "trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${myip_org} ${myip} ${myipv6} ${target_speed_up} Mbps)" >> ${myip}.txt
rm ${myip}.txt
else
echo "trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${myip_org} ${myip} ${myipv6} ${target_speed_up} Mbps)" &> ${myip}.txt
rm ${myip}.txt
fi
cd
if [[ ${install_dnscrypt} == 1 ]]; then
  if [[ ${dist} = ubuntu ]]; then
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
  fi
if [[ $(systemctl is-active dnsmasq) == active ]]; then
    systemctl disable dnsmasq
fi
echo "nameserver 127.0.0.1" > /etc/resolv.conf
systemctl restart dnscrypt-proxy
echo "nameserver 127.0.0.1" > /etc/resolvconf/resolv.conf.d/base
resolvconf -u
fi
cd
rm -rf /root/*.sh
rm -rf /usr/share/nginx/*.sh
clear
}

## 检测系统是否支援
initialize(){
TERM=ansi whiptail --title "初始化中(initializing)" --infobox "初始化中...(initializing)" 7 68
if [[ -f /etc/sysctl.d/60-disable-ipv6.conf ]]; then
  mv /etc/sysctl.d/60-disable-ipv6.conf /etc/sysctl.d/60-disable-ipv6.conf.bak
fi
if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
  dist="ubuntu"
  if [[ -f /etc/sysctl.d/60-disable-ipv6.conf.bak ]]; then
    sed -i 's/#//g' /etc/netplan/01-netcfg.yaml
    netplan apply
  fi
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 elif cat /etc/*release | grep ^NAME | grep -q Debian; then
  dist="debian"
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 else
  echo -e "操作系统不支援,请使用Debian或者Ubuntu运行 Please use Debian or Ubuntu."
  exit 1;
fi

## SSH 连接保活

sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 3/g" /etc/ssh/sshd_config

systemctl reload sshd

## 阻止日志文件过大占用系统空间

if grep "maxsize" /etc/logrotate.d/rsyslog; then

echo "日志最大大小设置已存在"

else

sed -e "/weekly/a\\
	maxsize 1G" < /etc/logrotate.d/rsyslog > tmp

cp -f tmp /etc/logrotate.d/rsyslog

cat /etc/logrotate.d/rsyslog

rm tmp

fi

## 卸载腾讯云云盾

rm -rf /usr/local/sa
rm -rf /usr/local/agenttools
rm -rf /usr/local/qcloud
rm -rf /usr/local/telescope

## 卸载阿里云云盾

cat /etc/apt/sources.list | grep aliyun &> /dev/null

if [[ $? == 0 ]] || [[ -d /usr/local/aegis ]]; then
curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/uninstall-aegis.sh
source uninstall-aegis.sh
uninstall_aegis
fi

localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
curl --ipv4 --retry 3 -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ip.json
if [[ $? != 0 ]]; then
curl --ipv4 --retry 3 -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ip.json
fi
myip="$( jq -r '.ip' "/root/.trojan/ip.json" )"
mycountry="$( jq -r '.country' "/root/.trojan/ip.json" )"
mycity="$( jq -r '.city' "/root/.trojan/ip.json" )"

myip_org="$( jq -r '.org' "/root/.trojan/ip.json" )"

IFS=' '

read -a strarr <<< "$myip_org"

org_temp="${strarr[1]}"

IFS=' '

read -a strarr2 <<< "$org_temp"

org="${strarr2[0]}"

echo $org
if echo "${myip_org}" | grep -q "AS13335"; then 
  warp_v4=1
fi

## Cloudflare Warp For IPv6 only server

if [[ -z ${myip} ]] && [[ -z ${localip} ]]; then
warp_v6=1
# https://github.com/P3TERX/warp.sh
apt install wireguard -y
modprobe wireguard
# curl -fsSL https://raw.githubusercontent.com/P3TERX/script/master/wgcf.sh | bash
# bash <(curl -fsSL https://raw.githubusercontent.com/P3TERX/warp.sh/main/warp.sh) wg4
curl -Ss https://raw.githubusercontent.com/kkkyg/CFwarp/main/CFwarp.sh | sudo bash

#   cat > '/etc/wireguard/wgcf.conf' << EOF
# # Generated by P3TERX/warp.sh
# # Visit https://github.com/P3TERX/warp.sh for more information

# [Interface]
# PrivateKey = tJY07jyP2L2yhBlt8JvTkhzsrhN9ljyRUHWyhIPawQc=
# Address = 172.16.0.2/32,fd01:5ca1:ab1e:89c4:1f:2c2e:ac99:cbe1/128
# DNS = 1.1.1.1,9.9.9.10,2606:4700:4700::1111,2001:4860:4860::8844
# MTU = 1420

# [Peer]
# PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
# AllowedIPs = 0.0.0.0/0,::/0
# Endpoint = [2606:4700:100::a29f:c109]:2408
# EOF
# systemctl restart wg-quick@wgcf.service
cd /root
curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g"
#curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g"
fi

}

## 初始化安装
install_initial(){
clear
if [[ -f /root/.trojan/config.json ]]; then
  install_status="$( jq -r '.installed' "/root/.trojan/config.json" )"
fi

if [[ $install_status != 1 ]]; then
  cp /etc/resolv.conf /etc/resolv.conf.bak1
  if [[ $(systemctl is-active caddy) == active ]]; then
      systemctl disable caddy --now
  fi
  if [[ $(systemctl is-active apache2) == active ]]; then
      systemctl disable apache2 --now
  fi
  if [[ $(systemctl is-active httpd) == active ]]; then
      systemctl disable httpd --now
  fi
fi
}

## 安装基础软件
install_base(){
set +e
TERM=ansi whiptail --title "安装中" --infobox "安装基础软件中..." 7 68
apt-get update
colorEcho ${INFO} "Installing all necessary Software"
apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release unzip resolvconf ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less neofetch -y
sh -c 'echo "y\n\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get install ntp -q -y'
clear
}

## 安装具体软件
install_moudles(){
  # Src url : https://github.com/johnrosen1/vpstoolbox/blob/master/install/

  if [[ ${install_docker} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/docker.sh
  source docker.sh
  install_docker
  fi
  if [[ ${install_php} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/php.sh
  source php.sh
  install_php
  fi
  if [[ ${install_mariadb} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mariadb.sh
  source mariadb.sh
  install_mariadb
  fi
  if [[ ${install_redis} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/redis.sh
  source redis.sh
  install_redis
  fi
  if [[ ${install_mongodb} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mongodb.sh
  source mongodb.sh
  install_mongodb
  fi
  if [[ ${install_grpc} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/grpc.sh
  source grpc.sh
  install_grpc
  fi
  if [[ ${install_ss_rust} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/ss-rust.sh
  source ss-rust.sh
  install_ss_rust
  fi
  if [[ ${install_aria} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/aria2.sh
  source aria2.sh
  install_aria2
  fi
  if [[ ${install_qbt_o} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/qbt_origin.sh
  source qbt_origin.sh
  install_qbt_o
  fi
  if [[ ${install_qbt_e} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/qbt.sh
  source qbt.sh
  install_qbt_e
  fi
  if [[ ${install_jellyfin} == 1 ]]; then
  #curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/jellyfin.sh
  #source jellyfin.sh
  #install_jellyfin
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/emby.sh
  source emby.sh
  install_emby
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/sonarr.sh
  source sonarr.sh
  install_sonarr
  fi
  if [[ ${install_fail2ban} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/fail2ban.sh
  source fail2ban.sh
  install_fail2ban
  fi
  if [[ ${install_filebrowser} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/filebrowser.sh
  source filebrowser.sh
  install_filebrowser
  fi
  if [[ ${install_mail} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mail.sh
  source mail.sh
  install_mail
  fi
  if [[ ${install_nextcloud} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nextcloud.sh
  source nextcloud.sh
  install_nextcloud
  fi
  if [[ ${install_rocketchat} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rocketchat.sh
  source rocketchat.sh
  install_rocketchat
  fi
  if [[ ${install_rss} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rss.sh
  source rss.sh
  install_rss
  fi
  if [[ ${install_speedtest} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/speedtest.sh
  source speedtest.sh
  install_speedtest
  fi
  if [[ ${install_tor} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/tor.sh
  source tor.sh
  install_tor
  fi
  if [[ ${install_tracker} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/tracker.sh
  source tracker.sh
  install_tracker
  fi
  if [[ ${install_rclone} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rclone.sh
  source rclone.sh
  install_rclone
  fi
  if [[ ${install_typecho} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/typecho.sh
  source typecho.sh
  install_typecho
  fi
  if [[ ${install_onedrive} == 1 ]]; then
  curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rclone_config.sh | sudo bash
  fi
  if [[ ${install_netdata} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/netdata.sh
  source netdata.sh
  install_netdata
  fi
  if [[ ${install_hexo} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/hexo.sh
  source hexo.sh
  install_hexo
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nodejs.sh
  source nodejs.sh
  install_nodejs
  fi
  if [[ ${install_alist} == 1 ]]; then
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/alist.sh
  source alist.sh
  install_alist
  fi
  ## Install Trojan-gfw
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/trojan.sh
  source trojan.sh
  install_trojan
  curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/route.sh
  source route.sh
  route_test
}

## 主菜单
MasterMenu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,下一步" --backtitle "Hi,欢迎使用VPSTOOLBOX。https://github.com/johnrosen1/vpstoolbox / https://t.me/vpstoolbox_chat。" --title "VPS ToolBox Menu" --menu --nocancel "Welcome to VPS Toolbox main menu,Please Choose an option 欢迎使用VPSTOOLBOX,请选择一个选项" 14 68 5 \
  "Install_standard" "基础安裝(简单易懂)" \
  "Install_extend" "高级安装(更多选择)" \
  "Benchmark" "效能测试"\
  "Uninstall" "卸载(仅能卸载基础安装)"\
  "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    ## 基础标准安装
    Install_standard)
    ## 初始化安装
    install_initial
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    ## 用户输入
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/userinput.sh
    source userinput.sh
    userinput_standard
    ## 检测证书是否已存在
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/detectcert.sh
    source detectcert.sh
    detectcert
    ## 开始安装
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/bbr.sh
    source bbr.sh
    install_bbr
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/system-upgrade.sh
    source system-upgrade.sh
    upgrade_system
    ## 基础软件安装
    install_base
    ## 开启防火墙
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/firewall.sh
    source firewall.sh
    openfirewall
    ## 安装NGINX
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx.sh
    source nginx.sh
    install_nginx
    ## 证书签发
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    if [[ ${ipissue} == 1 ]]; then
      ## 签发免费IP证书
      curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/ipcert.sh
      source ipcert.sh
      ip_issue
    else
      ## 签发域名证书
      curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/issuecert.sh
      source issuecert.sh
      ## HTTP证书签发
      if [[ ${httpissue} == 1 ]]; then
        http_issue
      fi
      ## DNS API证书签发
      if [[ ${dnsissue} == 1 ]]; then
        dns_issue
      fi
    fi    
    ## 具体软件安装
    install_moudles
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx-config.sh
    source nginx-config.sh
    nginx_config
    ## 带宽测试
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/speed.sh
    source speed.sh
    install_speed
    ## 安装 Hysteria
    if [[ ${install_hy} == 1 ]]; then
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/hysteria.sh
    source hysteria.sh
    install_hysteria
    fi
    ## 输出结果
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    apt-get install qrencode -y
    apt-get install pip python3 -y
    pip install pystun3
    apt-get install neofetch -y
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/output.sh
    source output.sh
    clean_env
    prase_output
    exit 0
    ;;
    ## 扩展安装
    Install_extend)
    ## 初始化安装
    install_initial
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    ## 用户输入
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/userinput.sh
    source userinput.sh
    userinput_full
    prasejson
    ## 检测证书是否已有
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/detectcert.sh
    source detectcert.sh
    detectcert
    ## 开始安装
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/system-upgrade.sh
    source system-upgrade.sh
    upgrade_system
    ## 基础软件安装
    install_base
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    ## 开启防火墙
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/firewall.sh
    source firewall.sh
    openfirewall
    ## 安装NGINX
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx.sh
    source nginx.sh
    install_nginx
    ## 证书签发
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/issuecert.sh
    source issuecert.sh
    ## HTTP证书签发
    if [[ ${httpissue} == 1 ]]; then
      http_issue
    fi
    ## DNS API证书签发
    if [[ ${dnsissue} == 1 ]]; then
      dns_issue
    fi
    ## 具体软件安装
    install_moudles
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx-config.sh
    source nginx-config.sh
    nginx_config
    ## 初始化Nextcloud
    if [[ ${install_nextcloud} == 1 ]] && [[ ${nextcloud_installed} != 1 ]]; then
    curl https://${domain}:${trojanport}/nextcloud/
    sleep 10s;
    ## Delete last line
    sed -i '$d' /usr/share/nginx/nextcloud/config/config.php
    echo "  'default_phone_region' => 'CN'," >> /usr/share/nginx/nextcloud/config/config.php
    echo "  'memcache.local' => '\\OC\\Memcache\\APCu'," >> /usr/share/nginx/nextcloud/config/config.php
    echo "  'memcache.distributed' => '\\OC\\Memcache\\Redis'," >> /usr/share/nginx/nextcloud/config/config.php
    echo "  'memcache.locking' => '\\OC\\Memcache\\Redis'," >> /usr/share/nginx/nextcloud/config/config.php
    echo "  'redis' => [" >> /usr/share/nginx/nextcloud/config/config.php
    echo "     'host'     => '/var/run/redis/redis.sock'," >> /usr/share/nginx/nextcloud/config/config.php
    echo "     'port'     => 0," >> /usr/share/nginx/nextcloud/config/config.php
    echo "     'timeout'  => 1.0," >> /usr/share/nginx/nextcloud/config/config.php
    echo "  ]," >> /usr/share/nginx/nextcloud/config/config.php
    echo ");" >> /usr/share/nginx/nextcloud/config/config.php
    fi
    ## 带宽测试
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/speed.sh
    source speed.sh
    install_speed
    ## 安装 Hysteria
    if [[ ${install_hy} == 1 ]]; then
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/hysteria.sh
    source hysteria.sh
    install_hysteria
    fi
    ## 输出结果
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.10" >> /etc/resolv.conf
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
    echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
    apt-get install qrencode -y
    apt-get install pip python3 -y
    pip install pystun3
    apt-get install neofetch -y
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/output.sh
    source output.sh
    clean_env
    prase_output
    exit 0
    ;;
    Benchmark)
    clear
    if (whiptail --title "测试模式" --yes-button "快速测试" --no-button "完整测试" --yesno "效能测试方式(fast or full)?" 8 68); then
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
        else
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s full
    fi
    exit 0
    ;;
    Exit)
    whiptail --title "Bash Exited" --msgbox "Goodbye" 8 68
    exit 0
    ;;
    Uninstall)
    curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/uninstall.sh
    source uninstall.sh
    uninstall
    exit 0
    ;;
    esac
}
cd /root
clear
curl --ipv4 --retry 3 -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 5 > /root/.trojan/ip.json
initialize
setlanguage
clear
MasterMenu
