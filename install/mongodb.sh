#!/usr/bin/env bash

## MongoDB模组 MongoDb moudle

set +e

install_mongodb(){
set +e
apt-get install gnupg2 -y
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
  cat > '/etc/apt/sources.list.d/mongodb-org-4.4.list' << EOF
deb http://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/4.4 main
EOF
  apt-get update
  apt-get install -y mongodb-org
  apt-get install -y python-pymongo
  systemctl start mongod
  systemctl enable mongod
}