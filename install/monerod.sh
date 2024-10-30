#!/usr/bin/env bash

## Monerod 完整节点模组 Monerod Full nodemoudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_monerod() {
curl --retry 5 -LO https://downloads.getmonero.org/linux64
tar -xjvf linux64
mv monero-x86_64* monero
cd monero
screen -d -m ./monerod --restricted-rpc --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind --rpc-ssl enabled
echo -e "Monerod Full node Install success !"
}

install_monerod
