#!/usr/bin/env bash

## Speedtest_cli 模组

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

mycountry="$( jq -r '.country' "/root/.trojan/ip.json" )"

install_speed(){
# https://github.com/sivel/speedtest-cli
curl --retry 5 -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update
apt-get install speedtest --allow-unauthenticated -y
mkdir /root/.config/
mkdir /root/.config/ookla/

  cat > '/root/.config/ookla/speedtest-cli.json' << EOF
{
    "Settings": {
        "LicenseAccepted": "604ec27f828456331ebf441826292c49276bd3c1bee1a2f65a6452f505c4061c"
    }
}
EOF

TERM=ansi whiptail --title "带宽测试" --infobox "带宽测试，请耐心等待。" 7 68
echo "YES" | /usr/bin/speedtest
/usr/bin/speedtest -f json | tee /root/.trojan/speed.json
port_down=$( jq -r '.download.bandwidth' "/root/.trojan/speed.json" )
port_up=$( jq -r '.upload.bandwidth' "/root/.trojan/speed.json" )

apt install bc -y

if (( $(echo "$port_up < 3000000" |bc -l) )); then
target_speed_down="30"
target_speed_up="30"
else
target_speed_down_bytes=$( jq -r '.download.bandwidth' "/root/.trojan/speed.json")
target_speed_up_bytes=$( jq -r '.upload.bandwidth' "/root/.trojan/speed.json")
target_speed_down=$(( target_speed_down_bytes*8/1000000 ))
target_speed_up=$(( target_speed_up_bytes*8/1000000 ))
echo $target_speed_down
echo $target_speed_up
fi

## CT China Telecom - Shanghai (id = 3633)
speedtest --server-id=3633 -f json | tee /root/.trojan/ct.json
## CU China Unicom 5G - ShangHai (id = 24447)
speedtest --server-id=24447 -f json | tee /root/.trojan/cu.json
## CM 中国移动江苏5G（中国镇江）
speedtest --server-id=17320 -f json | tee /root/.trojan/cm.json

ct_up_bytes=$( jq -r '.upload.bandwidth' "/root/.trojan/ct.json")
ct_up=$(( ct_up_bytes*8/1000000 ))
cu_up_bytes=$( jq -r '.upload.bandwidth' "/root/.trojan/cu.json")
cu_up=$(( cu_up_bytes*8/1000000 ))
cm_up_bytes=$( jq -r '.upload.bandwidth' "/root/.trojan/cm.json")
cm_up=$(( cm_up_bytes*8/1000000 ))
echo $ct_up
echo $cu_up
echo $cm_up
ct_down_bytes=$( jq -r '.download.bandwidth' "/root/.trojan/ct.json")
ct_down=$(( ct_down_bytes*8/1000000 ))
cu_down_bytes=$( jq -r '.download.bandwidth' "/root/.trojan/cu.json")
cu_down=$(( cu_down_bytes*8/1000000 ))
cm_down_bytes=$( jq -r '.download.bandwidth' "/root/.trojan/cm.json")
cm_down=$(( cm_down_bytes*8/1000000 ))
echo $ct_down
echo $cu_down
echo $cm_down
ct_latency=$( jq -r '.ping.latency' "/root/.trojan/ct.json")
cu_latency=$( jq -r '.ping.latency' "/root/.trojan/cu.json")
cm_latency=$( jq -r '.ping.latency' "/root/.trojan/cm.json")
echo $ct_latency
echo $cu_latency
echo $cm_latency
}