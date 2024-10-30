#!/usr/bin/env bash

## mariadb模组 mariadb moudle

set +e

install_mariadb(){
	set +e
  curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
  apt-get install mariadb-server -y
  #apt-get install python-mysqldb -y
  apt-get -y install expect

  SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Switch to unix_socket authentication\"
send \"n\r\"

expect \"Change the root password?\"
send \"n\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"

apt-get -y purge expect

    cat > '/etc/mysql/my.cnf' << EOF
# MariaDB-specific config file.
# Read by /etc/mysql/my.cnf

[client]

default-character-set = utf8mb4 

[mysqld]

max_allowed_packet = 16M
group_concat_max_len = 8192
max_connections = 2000
character-set-server  = utf8mb4 
collation-server      = utf8mb4_unicode_ci
character_set_server   = utf8mb4 
collation_server       = utf8mb4_unicode_ci
# Import all .cnf files from configuration directory
!includedir /etc/mysql/mariadb.conf.d/
bind-address=127.0.0.1

innodb_read_only_compressed=OFF

[mariadb]

userstat = 1
tls_version = TLSv1.2,TLSv1.3
# ssl_cert = /etc/certs/${domain}_ecc/fullchain.cer
# ssl_key = /etc/certs/${domain}_ecc/${domain}.key
EOF

# mysql -u root -e "create user 'netdata'@'localhost';"
# mysql -u root -e "grant usage on *.* to 'netdata'@'localhost';"
# mysql -u root -e "flush privileges;"

mysql -u root -e "CREATE DATABASE trojan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "create user 'trojan'@'localhost' IDENTIFIED BY '${password1}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON trojan.* to trojan@'localhost';"
mysql -u root -e "flush privileges;"

systemctl restart mariadb
}
