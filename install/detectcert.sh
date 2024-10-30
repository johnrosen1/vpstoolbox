#!/usr/bin/env bash

## 证书检测模组 Cert detect moudle

set +e

detectcert(){
    set +e
if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    apt-get install gnutls-bin -y
    openfirewall
    certtool -i < /etc/certs/${domain}_ecc/fullchain.cer --verify --verify-hostname=${domain}
    if [[ $? != 0 ]]; then
        whiptail --title "ERROR" --msgbox "无效的证书,可能过期或者域名不正确,启动证书续签程序" 8 68
        ~/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' &> /root/.trojan/letcron.log 2>&1
    fi
        crontab -l | grep acme.sh
        if [[ $? != 0 ]]; then
        colorEcho ${INFO} "CRON(证书续签模块)缺失,添加中..."
        crontab -l > mycron
        echo "0 0 * * 0 /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
        crontab mycron
        rm mycron        
    fi
fi

if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]] || [[ ${ipissue} == 1 ]]; then
      colorEcho ${INFO} "证书已有,跳过申请(skipping cert issue)"
    else
        if (whiptail --title "Issue TLS Cert" --yes-button "HTTP申请" --no-button "DNS API申请" --yesno "使用 (use) API/HTTP申请证书(to issue certificate)?" 8 68); then
        httpissue=1
        else
        dnsissue=1
    fi
fi
}
