#!/usr/bin/env bash

## 阿里云云盾卸载模组 Uninstall Aliyun-aegis moudle

set +e

uninstall_aegis(){
colorEcho ${INFO} "Uninstall Aliyun aegis ing"
systemctl stop aegis
systemctl stop CmsGoAgent.service
systemctl stop aliyun
systemctl stop cloud-config
systemctl stop cloud-final
systemctl stop cloud-init-local.service
systemctl stop cloud-init
systemctl stop ecs_mq
systemctl stop exim4
systemctl stop apparmor
systemctl stop sysstat
systemctl disable aegis
systemctl disable CmsGoAgent.service
systemctl disable aliyun
systemctl disable cloud-config
systemctl disable cloud-final
systemctl disable cloud-init-local.service
systemctl disable cloud-init
systemctl disable ecs_mq
systemctl disable exim4
systemctl disable sysstat
killall -9 aegis_cli >/dev/null 2>&1
killall -9 aegis_update >/dev/null 2>&1
killall -9 aegis_cli >/dev/null 2>&1
killall -9 AliYunDun >/dev/null 2>&1
killall -9 AliHids >/dev/null 2>&1
killall -9 AliHips >/dev/null 2>&1
killall -9 AliYunDunUpdate >/dev/null 2>&1
rm -rf /etc/init.d/aegis
rm -rf /etc/systemd/system/CmsGoAgent*
rm -rf /etc/systemd/system/aliyun*
rm -rf /lib/systemd/system/cloud*
rm -rf /lib/systemd/system/ecs_mq*
rm -rf /usr/local/aegis
rm -rf /usr/local/cloudmonitor
rm -rf /usr/sbin/aliyun*
rm -rf /sbin/ecs_mq_rps_rfs
rm -rf /usr/local/share/assist-daemon
for ((var=2; var<=5; var++)) do
  if [ -d "/etc/rc${var}.d/" ];then
    rm -rf "/etc/rc${var}.d/S80aegis"
  elif [ -d "/etc/rc.d/rc${var}.d" ];then
    rm -rf "/etc/rc.d/rc${var}.d/S80aegis"
  fi
done
apt-get purge sysstat exim4 chrony aliyun-assist -y
systemctl daemon-reload
# 更换apt源以防出bug
curl --retry 5 -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/system-upgrade.sh
source system-upgrade.sh
upgrade_system
#echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
}

