#!/usr/bin/env bash

## Nextcloud模组 Nextcloud moudle

set +e

install_nextcloud(){
  TERM=ansi whiptail --title "安装中" --infobox "安装nextcloud中..." 7 68
  apt-get install php8.1-redis -y
  apt-get install unzip -y
  apt-get install libmagickcore-6.q16-6-extra -y
  cd /usr/share/nginx
  if [[ -d /usr/share/nginx/nextcloud/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新nextcloud中..." 7 68
    curl --retry 5 -LO https://download.nextcloud.com/server/releases/latest.zip
    unzip -o latest.zip
    rm latest.zip
    chown -R nginx:nginx /usr/share/nginx/nextcloud/
    chmod +x /usr/share/nginx/nextcloud/occ
    nextcloud_installed=1
    cd
  else
  mysql -u root -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -u root -e "create user 'nextcloud'@'localhost' IDENTIFIED BY '${password1}';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* to nextcloud@'localhost';"
  mysql -u root -e "flush privileges;"
  curl --retry 5 -LO https://download.nextcloud.com/server/releases/latest.zip
  unzip -o latest.zip
  rm latest.zip
  mkdir /usr/share/nginx/nextcloud_data
  cd /usr/share/nginx/nextcloud/config
  cat > "autoconfig.php" << EOF
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "nextcloud",
  "dbuser"        => "nextcloud",
  "dbpass"        => "${password1}",
  "dbhost"        => "localhost:/run/mysqld/mysqld.sock",
  "dbtableprefix" => "",
  "adminlogin"    => "admin",
  "adminpass"     => "${password1}",
  "directory"     => "/usr/share/nginx/nextcloud_data",
);
EOF
  chown -R nginx:nginx /usr/share/nginx/
  chown -R nginx:nginx /etc/nginx/
  update-alternatives --set php /usr/bin/php8.1
  crontab -l > mycron
  echo "*/5 * * * * sudo -u nginx php --define apc.enable_cli=1 -f /usr/share/nginx/nextcloud/cron.php &> /dev/null" >> mycron
  crontab mycron
  rm mycron
  chmod +x /usr/share/nginx/nextcloud/occ
  cd
fi

mkdir /usr/share/nginx/tmp/

cd
}
