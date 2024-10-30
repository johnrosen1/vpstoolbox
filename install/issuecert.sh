#!/usr/bin/env bash

## 证书申请模组 Let's encrypt moudle

set +e

installacme(){
  set +e
  curl --retry 5 -s https://get.acme.sh | sh
  if [[ ! -f /root/.acme.sh/acme.sh ]]; then
    colorEcho ${ERROR} "安装acme.sh失败，请自行检查网络连接及DNS配置!"
    colorEcho ${ERROR} '请尝试手动安装 curl -s https://get.acme.sh | sh'
    exit 1
  fi
  ~/.acme.sh/acme.sh --upgrade --auto-upgrade
}

http_issue(){
set +e
installacme
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
touch /etc/nginx/conf.d/default.conf
openssl genrsa -out server.key 2048
openssl req -new -x509 -days 3650 -key server.key -out server.crt -subj "/C=CN/ST=mykey/L=mykey/O=mykey/OU=mykey/CN=domain1"
  cat > '/etc/nginx/conf.d/default.conf' << EOF
server {
  listen       80;
  listen       [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  ssl_certificate     /root/server.crt;
  ssl_certificate_key /root/server.key;
  server_name  _;
  root   /usr/share/nginx/html;
    location /.well-known/acme-challenge/ {
      root /usr/share/nginx/;
    }
}
EOF
  systemctl restart nginx
  clear
  colorEcho ${INFO} "申请证书中"
  ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue -w /usr/share/nginx/ --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl restart trojan postfix dovecot nginx || true"
  if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    :
    else
    colorEcho ${ERROR} "证书申请失败，请**检查VPS控制面板防火墙是否完全关闭**,DNS是否解析完成!!!"
    colorEcho ${ERROR} "请访问https://letsencrypt.status.io/检测Let's encrypt服务是否正常!!!"
    exit 1
  fi
  chmod +r /etc/certs/${domain}_ecc/fullchain.cer
  chmod +r /etc/certs/${domain}_ecc/${domain}.key
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
rm -rf /root/server.crt
rm -rf /root/server.key
}

dns_issue(){
whiptail --title "Warning" --msgbox "若你的域名厂商(或者准确来说你的域名的NS)不在下列列表中,请在上一个yes/no选项中选否(需要保证域名A解析已成功)或者open an github issue/pr" 8 68
    APIOPTION=$(whiptail --nocancel --clear --ok-button "吾意已決 立即執行" --title "API choose" --menu --separate-output "域名(domain)API：請按方向键來選擇(Use Arrow key to choose)" 15 68 6 \
"1" "Cloudflare" \
"2" "Namesilo" \
"3" "Aliyun" \
"4" "DNSPod.cn" \
"5" "CloudXNS.com" \
"6" "GoDaddy" \
"7" "Name.com" \
"http" "使用HTTP申请"  3>&1 1>&2 2>&3)

    case $APIOPTION in
        1)
        while [[ -z ${CF_Key} ]] || [[ -z ${CF_Email} ]]; do
        CF_Key=$(whiptail --passwordbox --nocancel "https://dash.cloudflare.com/profile/api-tokens，輸入你的CF Global Key併按回車" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        CF_Email=$(whiptail --inputbox --nocancel "https://dash.cloudflare.com/profile，輸入你的CF_Email併按回車" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        done
        export CF_Key="$CF_Key"
        export CF_Email="$CF_Email"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_cf --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        2)
        while [[ -z $Namesilo_Key ]]; do
        Namesilo_Key=$(whiptail --passwordbox --nocancel "https://www.namesilo.com/account_api.php，輸入你的Namesilo_Key併按回車" 8 68 --title "Namesilo_Key input" 3>&1 1>&2 2>&3)
        done
        export Namesilo_Key="$Namesilo_Key"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_namesilo --cert-home /etc/certs --dnssleep 1800 -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        3)
        while [[ -z $Ali_Key ]] || [[ -z $Ali_Secret ]]; do
        Ali_Key=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，輸入你的Ali_Key併按回車" 8 68 --title "Ali_Key input" 3>&1 1>&2 2>&3)
        Ali_Secret=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，輸入你的Ali_Secret併按回車" 8 68 --title "Ali_Secret input" 3>&1 1>&2 2>&3)
        done
        export Ali_Key="$Ali_Key"
        export Ali_Secret="$Ali_Secret"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_ali --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        4)
        while [[ -z $DP_Id ]] || [[ -z $DP_Key ]]; do
        DP_Id=$(whiptail --passwordbox --nocancel "DNSPod.cn，輸入你的DP_Id併按回車" 8 68 --title "DP_Id input" 3>&1 1>&2 2>&3)
        DP_Key=$(whiptail --passwordbox --nocancel "DNSPod.cn，輸入你的DP_Key併按回車" 8 68 --title "DP_Key input" 3>&1 1>&2 2>&3)
        done
        export DP_Id="$DP_Id"
        export DP_Key="$DP_Key"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_dp --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        5)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "CloudXNS.com，輸入你的CX_Key併按回車" 8 68 --title "CX_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "CloudXNS.com，輸入你的CX_Secret併按回車" 8 68 --title "CX_Secret input" 3>&1 1>&2 2>&3)
        done
        export CX_Key="$CX_Key"
        export CX_Secret="$CX_Secret"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_cx --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        6)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，輸入你的GD_Key" 8 68 --title "GD_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，輸入你的GD_Secret" 8 68 --title "GD_Secret input" 3>&1 1>&2 2>&3)
        done
        export GD_Key="$CX_Key"
        export GD_Secret="$CX_Secret"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_gd --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        7)
        while [[ -z $Namecom_Username ]] || [[ -z $Namecom_Token ]]; do
        Namecom_Username=$(whiptail --passwordbox --nocancel "https://www.name.com/account/settings/api，輸入你的Namecom_Username" 8 68 --title "Namecom_Username input" 3>&1 1>&2 2>&3)
        Namecom_Token=$(whiptail --passwordbox --nocancel "https://www.name.com/account/settings/api，輸入你的Namecom_Token" 8 68 --title "Namecom_Token input" 3>&1 1>&2 2>&3)
        done
        export Namecom_Username="$Namecom_Username"
        export Namecom_Token="$Namecom_Token"
        installacme
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --dns dns_namecom --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * * /root/.acme.sh/acme.sh --server letsencrypt --cron --cert-home /etc/certs --reloadcmd 'systemctl restart trojan postfix dovecot nginx hysteria || true' &> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        http)
    upgradesystem
        httpissue
        ;;
        *)
        ;;
    esac

if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    :
    else
    colorEcho ${ERROR} "DNS申请证书失败，尝试HTTP申请中."
    httpissue
  fi
}
