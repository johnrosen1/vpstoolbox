#!/usr/bin/env bash

## PHP模组 PHP moudle

set +e

install_php(){
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装PHP中..." 7 68
colorEcho ${INFO} "Install PHP ing"
apt-get purge php* -y
mkdir /usr/log/
if [[ ${dist} == debian ]]; then
    wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
    apt-get update
elif [[ ${dist} == ubuntu ]]; then
    add-apt-repository ppa:ondrej/php -y
    apt-get update
else
  echo "fail"
fi
  apt-get install php8.1-fpm -y
  apt-get install php8.1-json -y
  apt-get install php8.1-apcu php8.1-gmp php8.1-common php8.1-mysql php8.1-ldap php8.1-xml php8.1-readline php8.1-xmlrpc php8.1-curl php8.1-gd php8.1-imagick php8.1-fpm php8.1-dev php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-intl php8.1-bcmath -y
  apt-get purge apache* -y
  sed -i "s/;date.timezone.*/date.timezone = Asia\/Shanghai/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.enable=1/opcache.enable=1/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/" /etc/php/8.1/fpm/php.ini
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 2000G/" /etc/php/8.1/fpm/php.ini
  sed -i "s/post_max_size = 8M/post_max_size = 0/" /etc/php/8.1/fpm/php.ini
  sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=192/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=16/" /etc/php/8.1/fpm/php.ini
  if grep -q "opcache.fast_shutdown" /etc/php/8.1/fpm/php.ini
    then
    :
    else
    echo "" >> /etc/php/8.1/fpm/php.ini
    echo "opcache.fast_shutdown=1" >> /etc/php/8.1/fpm/php.ini
  fi
  if grep -q "redis.session.locking_enabled" /etc/php/8.1/fpm/php.ini
    then
    :
    else
    echo "" >> /etc/php/8.1/fpm/php.ini
    echo "redis.session.locking_enabled=1" >> /etc/php/8.1/fpm/php.ini
    echo "redis.session.lock_retries=10" >> /etc/php/8.1/fpm/php.ini
    echo "redis.session.lock_wait_time=10000" >> /etc/php/8.1/fpm/php.ini
    echo "expose_php=off" >> /etc/php/8.1/fpm/php.ini
  fi
  if grep -q "env[PATH]" /etc/php/8.1/fpm/php-fpm.conf
    then
    :
    else
    echo "" >> /etc/php/8.1/fpm/php-fpm.conf
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin:/usr/local/php/bin" >> /etc/php/8.1/fpm/php-fpm.conf
  fi
  if grep -q "apc.enabled_cli=1" /etc/php/8.1/fpm/conf.d/20-apcu.ini
    then
    :
    else
    echo "" >> /etc/php/8.1/fpm/conf.d/20-apcu.ini
    echo "apc.enabled_cli=1" >> /etc/php/8.1/fpm/conf.d/20-apcu.ini
  fi
  cd /etc/php/8.1/
  curl -sS https://getcomposer.org/installer -o composer-setup.php
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer --force
  cd
cat > '/etc/php/8.1/fpm/pool.d/www.conf' << EOF
[www]

user = nginx
group = nginx

listen = /run/php/php8.1-fpm.sock

listen.owner = nginx
listen.group = nginx

pm = dynamic

pm.max_children = $(($(nproc --all)*5))

pm.start_servers = $(($(nproc --all)*4))

pm.min_spare_servers = $(($(nproc --all)*2))

pm.max_spare_servers = $(($(nproc --all)*4))

pm.status_path = /status

ping.path = /ping

catch_workers_output = no

php_flag[display_errors] = off
php_admin_value[error_log] = /var/log/fpm-php.www.log
php_admin_flag[log_errors] = off
EOF
systemctl enable php8.1-fpm
systemctl restart php8.1-fpm
}
