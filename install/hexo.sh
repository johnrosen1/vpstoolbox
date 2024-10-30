#!/usr/bin/env bash

## Hexo模组 Hexo moudle

set +e

install_hexo(){
TERM=ansi whiptail --title "安装中" --infobox "安装Hexo中..." 7 68
  colorEcho ${INFO} "Install Hexo ing..."
  cd /usr/share/nginx
  npm install -g npm
  npm install hexo-cli -g
  npm update
  hexo init hexo
  cd /usr/share/nginx/hexo
  npm audit fix
  npm prune
  cd /usr/share/nginx/hexo/themes
  apt-get install git -y
  git clone https://github.com/theme-next/hexo-theme-next next
  cd /usr/share/nginx/hexo
  npm install hexo-generator-feed --save
  npm install hexo-filter-nofollow --save
  npm install hexo-migrator-rss --save
    cat > '/usr/share/nginx/hexo/_config.yml' << EOF
#title: xxx's Blog
#author: xxx
#description: xxx的博客。
language: zh-CN
url: https://${domain}
theme: next
post_asset_folder: true
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content: false
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
  icon: icon.png
  autodiscovery: true
  template:
nofollow:
  enable: true
  field: site
  exclude:
    - 'exclude1.com'
    - 'exclude2.com'
EOF

## Enable CC license (by-nc-sa)

sed -i '0,/sidebar: false/s//sidebar: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/post: false/s//post: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/darkmode: false/s//darkmode: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/lazyload: false/s//lazyload: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/lazyload: false/s//lazyload: true/' /usr/share/nginx/hexo/themes/next/_config.yml

hexo g

hexo_location=$(which hexo)
    cat > '/etc/systemd/system/hexo.service' << EOF
[Unit]
Description=Hexo Server Service
Documentation=https://hexo.io/zh-tw/docs/
After=network.target

[Service]
WorkingDirectory=/usr/share/nginx/hexo
ExecStart=${hexo_location} server -i 127.0.0.1
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hexo --now
cd
}
