#!/usr/bin/env bash

## JellyFin模组 Jellyfin moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_jellyfin(){
apt install -y apt-transport-https
wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo apt-key add -
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
apt-get update
apt-get install -y jellyfin
sed -i "s/<BaseUrl \/>/<BaseUrl>\/jellyfin\/<\/BaseUrl>/g" /etc/jellyfin/system.xml
sed -i "s/<EnableIPV6>false<\/EnableIPV6>/<EnableIPV6>true<\/EnableIPV6>/g" /etc/jellyfin/system.xml
sed -i "s/<EnableRemoteAccess>true<\/EnableRemoteAccess>/<EnableRemoteAccess>false<\/EnableRemoteAccess>/g" /etc/jellyfin/system.xml
sed -i "s/en-US/zh-CN/g" /etc/jellyfin/system.xml
sed -i "s/<PublicPort>8096<\/PublicPort>/<PublicPort>8099<\/PublicPort>/g" /etc/jellyfin/system.xml
sed -i "s/<BaseUrl \/>/<BaseUrl>\/jellyfin\/<\/BaseUrl>/g" /etc/jellyfin/network.xml
sed -i "s/<EnableIPV6>false<\/EnableIPV6>/<EnableIPV6>true<\/EnableIPV6>/g" /etc/jellyfin/network.xml
sed -i "s/<IgnoreVirtualInterfaces>true<\/IgnoreVirtualInterfaces>/<IgnoreVirtualInterfaces>false<\/IgnoreVirtualInterfaces>/g" /etc/jellyfin/network.xml
systemctl restart jellyfin
cd
}