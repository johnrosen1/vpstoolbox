#!/usr/bin/env bash

## i2pd模组 i2pd moudle

set +e

install_i2pd(){
  set +e
  if [[ ${dist} == debian ]]; then
wget -q -O - https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -
apt-get update
apt-get install minissdpd -y
apt-get install i2pd -y
 elif [[ ${dist} == ubuntu ]]; then
  add-apt-repository ppa:purplei2p/i2pd -y
  apt-get update
  apt-get install i2pd -y
 else
  echo "fail"
 fi
  cat > '/etc/i2pd/i2pd.conf' << EOF
log = syslog
## Path to logfile (default - autodetect)
# logfile = /var/log/i2pd/i2pd.log
## Log messages above this level (debug, info, *warn, error, none)
## If you set it to none, logging will be disabled
loglevel = none
## Write full CLF-formatted date and time to log (default: write only time)
# logclftime = true

## Daemon mode. Router will go to background after start
# daemon = true

## Port to listen for connections
## By default i2pd picks random port. You MUST pick a random number too,
## don't just uncomment this
# port = 9000

## Enable communication through ipv4
ipv4 = true
## Enable communication through ipv6
ipv6 = true

nat = false

## Enable NTCP transport (default = true)
# ntcp = true
## If you run i2pd behind a proxy server, you can only use NTCP transport with ntcpproxy option 
## Should be http://address:port or socks://address:port
# ntcpproxy = http://127.0.0.1:8118
## Enable SSU transport (default = true)
ssu = true
bandwidth = X
share = 100
notransit = false
floodfill = false

[http]
## Web Console settings
## Uncomment and set to 'false' to disable Web Console
# enabled = true
## Address and port service will listen on
address = 127.0.0.1
port = 7070
strictheaders = false
## Path to web console, default "/"
webroot = /
## Uncomment following lines to enable Web Console authentication 
# auth = true
# user = i2pd
# pass = changeme

[httpproxy]
## Uncomment and set to 'false' to disable HTTP Proxy
# enabled = true
## Address and port service will listen on
address = 127.0.0.1
port = 4444
## Enable address helper for adding .i2p domains with "jump URLs" (default: true)
# addresshelper = true
## Address of a proxy server inside I2P, which is used to visit regular Internet
# outproxy = http://false.i2p
## httpproxy section also accepts I2CP parameters, like "inbound.length" etc.
inbound.length = 1
#inbound.quantity = 16
outbound.length = 1
#outbound.quantity = 16

[socksproxy]
## Uncomment and set to 'false' to disable SOCKS Proxy
enabled = false
## Address and port service will listen on
address = 127.0.0.1
port = 4447
## Optional keys file for proxy local destination
# keys = socks-proxy-keys.dat
## Socks outproxy. Example below is set to use Tor for all connections except i2p
## Uncomment and set to 'true' to enable using of SOCKS outproxy
# outproxy.enabled = true
## Address and port of outproxy
# outproxy = 127.0.0.1
# outproxyport = 9050
## socksproxy section also accepts I2CP parameters, like "inbound.length" etc.
# inbound.length = 2
# inbound.quantity = 16
# outbound.length = 2
# outbound.quantity = 16

[sam]
## Uncomment and set to 'true' to enable SAM Bridge
enabled = false

[bob]
## Uncomment and set to 'true' to enable BOB command channel
enabled = false

[i2cp]
## Uncomment and set to 'true' to enable I2CP protocol
enabled = false

[i2pcontrol]
## Uncomment and set to 'true' to enable I2PControl protocol
# enabled = on
## Address and port service will listen on
# address = 127.0.0.1
# port = 7650
## Authentication password. "itoopie" by default
# password = ${password1}

[precomputation]
## Enable or disable elgamal precomputation table
## By default, enabled on i386 hosts
# elgamal = true

[upnp]
## Enable or disable UPnP: automatic port forwarding (enabled by default in WINDOWS, ANDROID)
enabled = false
## Name i2pd appears in UPnP forwardings list (default = I2Pd)
# name = I2Pd

[reseed]
## Options for bootstrapping into I2P network, aka reseeding
## Enable or disable reseed data verification.
verify = true
## URLs to request reseed data from, separated by comma
## Default: "mainline" I2P Network reseeds
# urls = https://reseed.i2p-projekt.de/,https://i2p.mooo.com/netDb/,https://netdb.i2p2.no/
## Path to local reseed data file (.su3) for manual reseeding
# file = /path/to/i2pseeds.su3
## or HTTPS URL to reseed from
# file = https://legit-website.com/i2pseeds.su3
## Path to local ZIP file or HTTPS URL to reseed from
# zipfile = /path/to/netDb.zip
## If you run i2pd behind a proxy server, set proxy server for reseeding here
## Should be http://address:port or socks://address:port
# proxy = http://127.0.0.1:8118
## Minimum number of known routers, below which i2pd triggers reseeding. 25 by default
# threshold = 25

[addressbook]
## AddressBook subscription URL for initial setup
## Default: inr.i2p at "mainline" I2P Network
# defaulturl = http://xk6ypey2az23vtdkitjxvanlshztmjs2ekd6sp77m4obszf6ocfq.b32.i2p/hosts.txt
## Optional subscriptions URLs, separated by comma
# subscriptions = http://xk6ypey2az23vtdkitjxvanlshztmjs2ekd6sp77m4obszf6ocfq.b32.i2p/alive-hosts.txt,http://kqypgjpjwrphnzebod5ev3ts2vtii6e5tntrg4rnfijqc7rypldq.b32.i2p/cgi-bin/newhosts.txt,http://gh6655arkncnbrzq5tmq4xpn36734d4tdza6flbw5xppye2dt6ga.b32.i2p/hosts.txt,http://udhdrtrcetjm5sxzskjyr5ztpeszydbh4dpl3pl4utgqqw2v4jna.b32.i2p/hosts.txt,http://rus.i2p/hosts.txt

[limits]
## Maximum active transit sessions (default:2500)
transittunnels = 1
## Limit number of open file descriptors (0 - use system limit)  
openfiles = 0
## Maximum size of corefile in Kb (0 - use system limit) 
coresize = 0
## Threshold to start probabalistic backoff with ntcp sessions (0 - use system limit) 
ntcpsoft = 0
## Maximum number of ntcp sessions (0 - use system limit) 
ntcphard = 0

[trust]
## Enable explicit trust options. false by default
# enabled = true
## Make direct I2P connections only to routers in specified Family.
# family = MyFamily
## Make direct I2P connections only to routers specified here. Comma separated list of base64 identities.
# routers = 
## Should we hide our router from other routers? false by default
# hidden = true

[exploratory]
## Exploratory tunnels settings with default values
inbound.length = 1
inbound.quantity = 0
outbound.length = 1
outbound.quantity = 0

[ntcp2]

enabled = true
published = true

[persist]
profiles = true

[cpuext]
## Use CPU AES-NI instructions set when work with cryptography when available (default: true)
# aesni = true
## Use CPU AVX instructions set when work with cryptography when available (default: true)
# avx = true
## Force usage of CPU instructions set, even if they not found
## DO NOT TOUCH that option if you really don't know what are you doing!
# force = false
EOF

echo "" > /etc/i2pd/tunnels.conf

#     cat > '/etc/i2pd/tunnels.conf.d/mywebsite.conf' << EOF
# [my-website]
# type = http
# host = 127.0.0.1
# port = 80
# inbound.length = 1
# outbound.length = 1
# #inbound.quantity = 16
# #outbound.quantity = 16
# keys = my-website.dat
# EOF
cd
    cat > '/lib/systemd/system/i2pd.service' << EOF
[Unit]
Description=I2P Router written in C++
Documentation=man:i2pd(1) https://i2pd.readthedocs.io/en/latest/
After=network.target

[Service]
User=i2pd
Group=i2pd
#RuntimeDirectory=i2pd
#RuntimeDirectoryMode=0700
#LogsDirectory=i2pd
#LogsDirectoryMode=0700
Type=forking
ExecStart=/usr/sbin/i2pd --conf=/etc/i2pd/i2pd.conf --tunconf=/etc/i2pd/tunnels.conf --tunnelsdir=/etc/i2pd/tunnels.conf.d --pidfile=/run/i2pd/i2pd.pid --logfile=/var/log/i2pd/i2pd.log --daemon --service
ExecReload=/bin/sh -c "kill -HUP $MAINPID"
PIDFile=/run/i2pd/i2pd.pid

KillSignal=SIGQUIT
# If you have the patience waiting 10 min on restarting/stopping it, uncomment this.
# i2pd stops accepting new tunnels and waits ~10 min while old ones do not die.
#KillSignal=SIGINT
#TimeoutStopSec=10m

LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable i2pd --now
cd
}
