#!/usr/bin/env bash

## 系统升级模组 System upgrade moudle

set +e

upgrade_system(){

## Install lastest ubuntu lts
if [[ $dist == ubuntu ]]; then
    cat > '/etc/apt/sources.list' << EOF
deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu focal partner
EOF
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -q -y'
  clear
else
## Install lastest stable debian
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
    cat > '/etc/apt/sources.list' << EOF
deb http://deb.debian.org/debian/ stable main contrib non-free
deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb http://deb.debian.org/debian-security stable-security main
EOF
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -q -y'
  clear
fi
}
