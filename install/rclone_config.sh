#!/usr/bin/env bash

## 全自动Rclone配置模组  Auto Rclone config moudle

## 使用方法: curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rclone_config.sh | sudo bash

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

config_rclone_onedrive() {
  ## 本选项用于防止档案名称冲突
  rname=$(whiptail --inputbox --nocancel "请输入Rclone档案名称,默认即可,不需要修改" 8 68 onedrive --title "rclone name input" 3>&1 1>&2 2>&3)
  if [[ -z ${rname} ]]; then
  rname="onedrive"
  fi

  if [[ ! -f /usr/bin/rclone ]]; then
  	curl https://rclone.org/install.sh | bash
  	apt-get install fuse -y
  fi

  if [[ ! -f /usr/bin/jq ]]; then
  	apt-get install jq -y
  fi

  TERM=ansi whiptail --title "开始配置 Rclone onedrive" --infobox "开始配置 Rclone onedrive" 7 68

  Region=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "请选择 onedrive region" --title "onedrive region选择" --menu --nocancel "请选择 onedrive region" 14 68 5 \
  "global" "Microsoft Cloud Global" \
  "cn" "Azure and Office 365 operated by 21Vianet in China" \
  "us" "Microsoft Cloud for US Government" \
  "de" "Microsoft Cloud Germany"\
  "test" "test-only" 3>&1 1>&2 2>&3)
  case $Region in
    global)
    region="global"
    ;;
    us)
    region="us"
    ;;
    de)
    region="de"
    ;;
    cn)
    region="cn"
    ;;
    esac


  client_id=$(whiptail --inputbox --nocancel "请输入 client_id" 8 68 --title "client_id input" 3>&1 1>&2 2>&3)
  if [[ -z ${client_id} ]]; then
  client_id="64110a82-a430-4cd0-9c83-5f671764424f"
  fi

  client_secret=$(whiptail --inputbox --nocancel "请输入 client_secret" 8 68 --title "client_secret input" 3>&1 1>&2 2>&3)
  if [[ -z ${client_secret} ]]; then
  client_secret="pKo_ySmLfjM-zNo36v.a2TwC95S-OTT9_B"
  fi

  whiptail --title "Oauth2授权命令(Windows)" --msgbox "rclone authorize \"onedrive\" -- \"${client_id}\" \"${client_secret}\"" 8 68

  echo -e "请在你自己的电脑上运行以下命令(windows)"
  echo -e "rclone authorize \"onedrive\" -- \"${client_id}\" \"${client_secret}\""
  echo "按下回车键以继续"
  read -n 1 -r -s -p $'Press enter to continue...\n'

  access_token=$(whiptail --inputbox --nocancel "请输入 access_token" 8 68 --title "access_token input" 3>&1 1>&2 2>&3)
  if [[ -z ${access_token} ]]; then
  access_token=$(whiptail --inputbox --nocancel "请输入 access_token" 8 68 --title "access_token input" 3>&1 1>&2 2>&3)
  fi

  echo "${access_token}" > access.json

  access_token_real="$( jq -r '.access_token' "access.json" )"
  echo "调用access token: ${access_token_real}"

  curl -H "Authorization: Bearer ${access_token_real}" https://graph.microsoft.com/v1.0/me/drives > info.json

  drive_id="$( jq -r '.value[] | .id' "info.json" )"
  drive_type="$( jq -r '.value[] | .driveType' "info.json" )"

mkdir /root/.config/rclone/
touch /root/.config/rclone/rclone.conf

  ## 写入Onedrive配置
  cat > '/root/.config/rclone/rclone.conf' << EOF
[${rname}]
type = onedrive
client_id = ${client_id}
client_secret = ${client_secret}
region = ${region}
token = ${access_token}
drive_id = ${drive_id}
drive_type = ${drive_type}

EOF

}

config_rclone_onedrive

TERM=ansi whiptail --title "Rclone onedrive配置完成" --infobox "Rclone onedrive配置完成" 7 68

rclone lsd onedrive: