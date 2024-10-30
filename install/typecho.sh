#!/usr/bin/env bash

## typecho模组 typecho moudle

set +e

install_typecho(){
	cd /usr/share/nginx/
	curl --retry 5 -LO https://github.com/typecho/typecho/releases/latest/download/typecho.zip
	unzip typecho.zip
	rm *.zip
	mv build typecho
	mysql -u root -e "CREATE DATABASE typecho CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "create user 'typecho'@'localhost' IDENTIFIED BY '${password1}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON typecho.* to typecho@'localhost';"
    mysql -u root -e "flush privileges;"
}