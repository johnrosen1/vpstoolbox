#!/usr/bin/env bash

## 用户输入模组 User Input moudle

set +e

userinput_standard() {
  clear

## 内存大小感知

memory_size=$(grep MemTotal /proc/meminfo | awk '{print $2}')

echo $memory_size

if [[ $memory_size < 200000 ]]; then 

echo "内存不足"
check_grpc="off"

else

echo "内存足够"
check_grpc="on"

fi


  tcp_fastopen="true"

  if [[ ${install_status} == 1 ]]; then
    if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
      readconfig
    fi
  fi

  if [[ -z ${check_trojan} ]]; then
    check_trojan="on"
  fi
  if [[ -z ${check_dns} ]]; then
    check_dns="off"
  fi
  if [[ -z ${check_speed} ]]; then
    check_speed="on"
  fi
  if [[ -z ${check_cloud} ]]; then
    check_cloud="off"
  fi
  if [[ -z ${check_rss} ]]; then
    check_rss="off"
  fi
  if [[ -z ${check_fail2ban} ]]; then
    check_fail2ban="on"
  fi
  if [[ -z ${check_ss} ]]; then
    check_ss="off"
  fi
  if [[ -z ${fastopen} ]]; then
    fastopen="on"
  fi

  if [[ -z ${check_ip} ]]; then
    check_ip="off"
  fi

  if [[ -z ${check_hy} ]]; then
    check_hy="off"
  fi

  if [[ -z ${check_aria} ]]; then
    check_aria="off"
  fi

  if [[ -z ${check_grpc} ]]; then
    check_grpc="on"
  fi

  whiptail --clear --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "应用安装菜单" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的应用程序。" 18 65 10 \
  "Back" "返回上级菜单(Back to main menu)" off \
  "trojan" "Trojan-GFW+TCP-BBR" on \
  "grpc" "Vless+gRPC(支持CDN)" ${check_grpc} \
  "alist" "alist网盘管理器" on \
  "speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
  "port" "自定义Trojan-GFW/Vless(grpc)端口" off \
  "hy" "hysteria(仅推荐用于垃圾线路)" ${check_hy} \
  "ip" "免费ip证书(没有域名的话选这个)" ${check_ip} \
  "hexo" "Hexo Blog" off \
  "aria" "Aria2+AriaNG+Filebrowser" ${check_aria} \
  "ss" "shadowsocks-rust(不支持CDN)" ${check_ss} \
  "rss" "RSSHUB + Miniflux(RSS生成器+RSS阅读器)" ${check_rss} \
  "fail2ban" "Fail2ban(防SSH爆破用)" on \
  "net" "Netdata(监测伺服器运行状态)" off 2>results

  while read choice; do
    case $choice in
    Back)
      MasterMenu
      break
      ;;
    trojan)
      install_trojan=1
      install_bbr=1
      ;;
    alist)
      install_hexo=0
      install_alist=1
      ;;
    hy)
      install_hy=1
      ;;
    ip)
      ipissue=1
      domain=${myip}
      ;;
    aria)
      check_aria="on"
      install_aria=1
      check_file="on"
      install_filebrowser=1
      install_tracker=1
      ;;
    hexo)
      install_hexo=1
      install_alist=0
      ;;
    ss)
      check_ss="on"
      install_ss_rust=1
      ;;
    grpc)
      install_grpc=1
      ;;
    net)
      install_netdata=1
      ;;
    speed)
      check_speed="on"
      install_speedtest=1
      install_php=1
      ;;
    rss)
      check_rss="on"
      install_rss=1
      install_docker=1
      install_redis=1
      ;;
    fail2ban)
      check_fail2ban="on"
      install_fail2ban=1
      ;;
    port)
      trojan_other_port=1
      ;;
    *) ;;

    esac
  done <results

  rm results

  if [[ ${ipissue} == 1 ]]; then
    while [[ -z ${zerossl_api} ]]; do
      zerossl_api=$(whiptail --inputbox --nocancel "请输入你的zerossl api https://app.zerossl.com/developer" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
    done
  fi

  if [[ ${install_hexo} == 1 ]] && [[ ${install_alist} == 1 ]]; then
    install_hexo=0
    install_alist=1
  fi

  if [[ ${trojan_other_port} == 1 ]]; then
    trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
    if [[ -z ${trojanport} ]]; then
      trojanport="443"
    fi
  fi

  while [[ -z ${domain} ]]; do
    domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
  done
  clear
  #hostnamectl set-hostname ${domain}
  #echo "${domain}" > /etc/hostname
  rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
  rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
  #echo "" >> /etc/hosts
  #echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
  if [[ ${install_trojan} = 1 ]]; then
    while [[ -z ${password1} ]]; do
      password1=$(whiptail --inputbox --nocancel "VPSToolBox系统主密码 (***请勿添加特殊符号***)" 8 68 --title "password1 input" 3>&1 1>&2 2>&3)
      if [[ -z ${password1} ]]; then
        password1=$(
          head /dev/urandom | tr -dc a-z0-9 | head -c 6
          echo ''
        )
      fi
    done
    while [[ -z ${password2} ]]; do
        password2=$(
          head /dev/urandom | tr -dc a-z0-9 | head -c 6
          echo ''
        )
    done
  fi
  if [[ ${password1} == ${password2} ]]; then
    password2=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ -z ${password1} ]]; then
    password1=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ -z ${password2} ]]; then
    password2=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
      ariapath="/jsonrpc"
    done
    while [[ -z $ariapasswd ]]; do
      ariapasswd=${password1}
    done
  fi
}

userinput_full() {
  set +e
  clear
  if [[ ${install_status} == 1 ]]; then
    if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
      readconfig
    fi
  fi

  if [[ -z ${check_trojan} ]]; then
    check_trojan="on"
  fi
  if [[ -z ${check_dns} ]]; then
    check_dns="off"
  fi
  if [[ -z ${check_rss} ]]; then
    check_rss="off"
  fi
  if [[ -z ${check_chat} ]]; then
    check_chat="off"
  fi
  if [[ -z ${check_qbt} ]]; then
    check_qbt="off"
  fi
  if [[ -z ${check_aria} ]]; then
    check_aria="off"
  fi
  if [[ -z ${check_file} ]]; then
    check_file="off"
  fi
  if [[ -z ${check_speed} ]]; then
    check_speed="on"
  fi
  if [[ -z ${check_mariadb} ]]; then
    check_mariadb="off"
  fi
  if [[ -z ${check_fail2ban} ]]; then
    check_fail2ban="on"
  fi
  if [[ -z ${check_mail} ]]; then
    check_mail="off"
  fi
  if [[ -z ${check_qbt_origin} ]]; then
    check_qbt_origin="off"
  fi
  if [[ -z ${check_tracker} ]]; then
    check_tracker="off"
  fi
  if [[ -z ${check_cloud} ]]; then
    check_cloud="off"
  fi
  if [[ -z ${check_tor} ]]; then
    check_tor="off"
  fi
  if [[ -z ${check_ss} ]]; then
    check_ss="off"
  fi
  if [[ -z ${check_rclone} ]]; then
    check_rclone="off"
  fi
  if [[ -z ${check_echo} ]]; then
    check_echo="off"
  fi
  if [[ -z ${fastopen} ]]; then
    fastopen="on"
  fi

  if [[ -z ${check_ip} ]]; then
    check_ip="off"
  fi

  if [[ -z ${check_hy} ]]; then
    check_hy="off"
  fi

  if [[ -z ${check_grpc} ]]; then
    check_grpc="on"
  fi

  whiptail --clear --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "应用安装菜单" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的应用程序。" 24 65 16 \
  "Back" "返回上级菜单(Back to main menu)" off \
  "trojan" "Trojan-GFW+TCP-BBR" on \
  "grpc" "Vless+gRPC+TLS(支持CDN)" ${check_grpc} \
  "alist" "alist网盘管理器" on \
  "speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
  "port" "自定义Trojan-GFW/Vless(grpc)端口" off \
  "hy" "Hysteria(仅推荐用于垃圾线路)" ${check_hy} \
  "ip" "免费ip证书(没有域名的话选这个)" ${check_ip} \
  "hexo" "Hexo Blog" off \
  "ss" "shadowsocks-rust(不支持CDN)" ${check_ss} \
  "media" "Emby Sonarr Radarr Lidarr Prowlarr Qbt" off \
  "rss" "RSSHUB + Miniflux(RSS生成器+RSS阅读器)" ${check_rss} \
  "rclone" "Rclone" ${check_rclone} \
  "aria" "Aria2+AriaNG+Filebrowser" ${check_aria} \
  "onedrive" "Rclone Onedrive" ${check_rclone} \
  "chat" "Rocket Chat" ${check_chat} \
  "mail" "Mail service(邮箱服务)" ${check_mail} \
  "fail2ban" "Fail2ban(防SSH爆破用)" on \
  "net" "Netdata(监测伺服器运行状态)" off \
  "nextcloud" "Nextcloud(私人网盘)" ${check_cloud} \
  "typecho" "Typecho" ${check_echo} \
  "qbt" "Qbittorrent增强版+高性能Tracker+Filebrowser(BT专用)" ${check_qbt} \
  "13" "Qbt原版+高性能Tracker+Filebrowser(PT专用)" off 2>results

  while read choice; do
    case $choice in
    Back)
      MasterMenu
      break
      ;;
    trojan)
      install_trojan=1
      install_bbr=1
      ;;
    alist)
      install_hexo=0
      install_alist=1
      ;;
    hexo)
      install_hexo=1
      install_alist=0
      ;;
    hy)
      install_hy=1
      ;;
    ip)
      ipissue=1
      domain=${myip}
      ;;
    ss)
      check_ss="on"
      install_ss_rust=1
      ;;
    typecho)
      install_php=1
      install_mariadb=1
      check_echo="on"
      install_typecho=1
      ;;
    onedrive)
      install_onedrive=1
      ;;
    dns)
      check_dns="on"
      install_dnscrypt=1
      ;;
    media)
      install_jellyfin=1
      install_docker=1
      install_qbt_e=1
      install_tracker=1
      ;;
    grpc)
      install_grpc=1
      ;;
    chat)
      install_rocketchat=1
      install_docker=1
      ;;
    net)
      install_netdata=1
      ;;
    nextcloud)
      install_nextcloud=1
      install_php=1
      install_mariadb=1
      install_redis=1
      ;;
    rss)
      check_rss="on"
      install_rss=1
      install_docker=1
      install_redis=1
      ;;
    qbt)
      check_tracker="on"
      check_qbt="on"
      install_qbt_e=1
      install_tracker=1
      check_file="on"
      install_filebrowser=1
      ;;
    aria)
      check_aria="on"
      install_aria=1
      check_file="on"
      install_filebrowser=1
      install_tracker=1
      ;;
    rclone)
      check_rclone="on"
      install_rclone=1
      ;;
    speed)
      check_speed="on"
      install_speedtest=1
      install_php=1
      ;;
    fail2ban)
      check_fail2ban="on"
      install_fail2ban=1
      ;;
    mail)
      check_mail="on"
      install_mail=1
      install_php=1
      install_mariadb=1
      ;;
    tor)
      install_tor=1
      install_docker=1
      ;;
    13)
      check_tracker="on"
      check_qbt_origin="on"
      install_qbt_o=1
      install_tracker=1
      check_file="on"
      install_filebrowser=1
      ;;
    port)
      trojan_other_port=1
      ;;
    *) ;;

    esac
  done <results

  rm results

  if [[ ${ipissue} == 1 ]]; then
    while [[ -z ${zerossl_api} ]]; do
      zerossl_api=$(whiptail --inputbox --nocancel "请输入你的zerossl api https://app.zerossl.com/developer" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
    done
  fi

  if [[ ${install_hexo} == 1 ]] && [[ ${install_alist} == 1 ]]; then
    install_hexo=0
    install_alist=1
  fi

  if [[ ${trojan_other_port} == 1 ]]; then
    trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
    if [[ -z ${trojanport} ]]; then
      trojanport="443"
    fi
  fi

  while [[ -z ${domain} ]]; do
    domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
  done
  clear
  #hostnamectl set-hostname ${domain}
  #echo "${domain}" > /etc/hostname
  rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
  rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
  #echo "" >> /etc/hosts
  #echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
  if [[ ${install_trojan} = 1 ]]; then
    while [[ -z ${password1} ]] || [[ ${n} > 30 ]]; do
        password1=$(whiptail --passwordbox --nocancel "VPSToolBox系统主密码 (**最长30字符，请勿添加特殊符号**)" 8 68 --title "设置主系统密码" 3>&1 1>&2 2>&3)
        n=${#password1}
      if [[ ${n} == 0 ]]; then
        password1=$(
          head /dev/urandom | tr -dc a-z0-9 | head -c 6
          echo ''
        )
      fi
      if [[ ${n} > 30 ]]; then
        password1=""
      fi
    done
    while [[ -z ${password2} ]]; do
        password2=$(
          head /dev/urandom | tr -dc a-z0-9 | head -c 6
          echo ''
        )
    done
  fi
  if [[ ${password1} == ${password2} ]]; then
    password2=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ -z ${password1} ]]; then
    password1=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ -z ${password2} ]]; then
    password2=$(
      head /dev/urandom | tr -dc a-z0-9 | head -c 6
      echo ''
    )
  fi
  if [[ ${install_mail} == 1 ]]; then
    mailuser=$(whiptail --inputbox --nocancel "Please enter your desired mailusername(邮箱用户名)" 8 68 admin --title "Mail user input" 3>&1 1>&2 2>&3)
    if [[ -z ${mailuser} ]]; then
      mailuser=$(
        head /dev/urandom | tr -dc a-z | head -c 4
        echo ''
      )
    fi
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
      ariapath="/jsonrpc"
    done
    while [[ -z $ariapasswd ]]; do
      ariapasswd=${password1}
    done
  fi
}
