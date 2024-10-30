#!/usr/bin/env bash

## Docker模组 Docker moudle

set +e

install_docker(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Docker中..." 7 68
colorEcho ${INFO} "安装Docker(Install Docker ing)"
if [[ ${dist} == debian ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io -y
elif [[ ${dist} == ubuntu ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io -y
else
  echo "fail"
fi
  cat > '/etc/docker/daemon.json' << EOF
{
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}
EOF
## Install Docker Compose

dockerver=$(curl --retry 5 -s "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl --retry 5 -L "https://github.com/docker/compose/releases/download/${dockerver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
systemctl restart docker
}