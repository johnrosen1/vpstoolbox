#!/usr/bin/env bash

## Firewall模组 Firewall moudle

set +e

openfirewall(){
TERM=ansi whiptail --title "配置中" --infobox "配置防火墙中..." 7 68
colorEcho ${INFO} "设置 firewall"
#policy
iptables -P INPUT ACCEPT &>/dev/null
iptables -P FORWARD ACCEPT &>/dev/null
iptables -P OUTPUT ACCEPT &>/dev/null
ip6tables -P INPUT ACCEPT &>/dev/null
ip6tables -P FORWARD ACCEPT &>/dev/null
ip6tables -P OUTPUT ACCEPT &>/dev/null
#flash
iptables -F &>/dev/null
ip6tables -F &>/dev/null
#tcp
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT  &>/dev/null #HTTPS
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT &>/dev/null #HTTP
iptables -A INPUT -p tcp -m tcp --dport ${trojanport} -j ACCEPT  &>/dev/null #HTTPS
iptables -A INPUT -p tcp -m tcp --dport ${trojanport} -j ACCEPT &>/dev/null #HTTP
#udp
iptables -A INPUT -p udp -m udp --dport 443 -j ACCEPT &>/dev/null
iptables -A INPUT -p udp -m udp --dport 80 -j ACCEPT &>/dev/null
iptables -A OUTPUT -j ACCEPT &>/dev/null
#tcp6
ip6tables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT &>/dev/null #HTTPSv6
ip6tables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT &>/dev/null #HTTPv6
#udp6
ip6tables -A INPUT -p udp -m udp --dport 443 -j ACCEPT &>/dev/null
ip6tables -A INPUT -p udp -m udp --dport 80 -j ACCEPT &>/dev/null
ip6tables -A OUTPUT -j ACCEPT &>/dev/null
if [[ ${install_mail} == 1 ]]; then
    iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT &>/dev/null
    iptables -A INPUT -p udp -m udp --dport 25 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p udp -m udp --dport 25 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT &>/dev/null
fi
apt-get install nftables -y
systemctl enable nftables.service
}