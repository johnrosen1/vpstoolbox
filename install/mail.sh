#!/usr/bin/env bash

## 邮箱模组 Mail moudle

  set +e

install_mail(){
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装邮件服务中..." 7 68
  colorEcho ${INFO} "Install Mail Service ing"
  apt-get install postfix postfix-pcre -y
  apt-get install postfix-policyd-spf-python -y
  apt-get install opendmarc -y
  systemctl enable opendmarc
  sed -i 's/Socket local:\/var\/run\/opendmarc\/opendmarc.sock/Socket local:\/var\/spool\/postfix\/opendmarc\/opendmarc.sock/' /etc/opendmarc.conf
  sed -i 's/SOCKET=local:\$RUNDIR\/opendmarc.sock/SOCKET=local:\/var\/spool\/postfix\/opendmarc\/opendmarc.sock/' /etc/default/opendmarc
  mkdir -p /var/spool/postfix/opendmarc
  chown opendmarc:opendmarc /var/spool/postfix/opendmarc -R
  chmod 750 /var/spool/postfix/opendmarc/ -R
  adduser postfix opendmarc
  systemctl restart opendmarc
  echo ${domain} > /etc/mailname
  cat > '/etc/postfix/main.cf' << EOF
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP \$mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 2
smtpd_tls_loglevel = 1
smtpd_tls_security_level = may
smtpd_tls_received_header = yes
smtpd_tls_eccert_file = /etc/certs/${domain}_ecc/fullchain.cer
smtpd_tls_eckey_file = /etc/certs/${domain}_ecc/${domain}.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtpd_tls_mandatory_ciphers = high
smtpd_tls_mandatory_exclude_ciphers = aNULL
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_dns_support_level=dnssec
smtp_host_lookup = native
smtp_tls_loglevel = 1
smtp_tls_security_level = dane
smtp_tls_mandatory_exclude_ciphers = aNULL, ECDHE-ECDSA-AES256-SHA384, ECDHE-ECDSA-AES128-SHA256, ECDHE-ECDSA-CAMELLIA256-SHA384, ECDHE-ECDSA-AES256-SHA, ECDHE-ECDSA-CAMELLIA128-SHA256, ECDHE-ECDSA-AES128-SHA
smtp_tls_connection_reuse = no
smtp_tls_eccert_file = /etc/certs/${domain}_ecc/fullchain.cer
smtp_tls_eckey_file = /etc/certs/${domain}_ecc/${domain}.key
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_sasl_type = dovecot
smtpd_sasl_security_options = noanonymous
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_authenticated_header = no
myhostname = ${domain}
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = \$myhostname, ${domain}, localhost.${domain}, localhost
relayhost = 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 ${myip}/32
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4, ipv6
message_size_limit = 52428800
smtpd_helo_required = yes
disable_vrfy_command = yes
policyd-spf_time_limit = 3600
#smtpd_helo_restrictions = permit_mynetworks permit_sasl_authenticated reject_non_fqdn_helo_hostname reject_invalid_helo_hostname reject_unknown_helo_hostname
smtpd_sender_restrictions = permit_mynetworks permit_sasl_authenticated reject_unknown_sender_domain reject_unknown_client_hostname
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination,check_policy_service unix:private/policyd-spf
milter_default_action = accept
milter_protocol = 6
smtpd_milters = local:opendkim/opendkim.sock,local:opendmarc/opendmarc.sock,local:spamass/spamass.sock
non_smtpd_milters = local:opendkim/opendkim.sock,local:opendmarc/opendmarc.sock,local:spamass/spamass.sock
smtp_header_checks = regexp:/etc/postfix/smtp_header_checks
mailbox_transport = lmtp:unix:private/dovecot-lmtp
smtputf8_enable = yes
tls_ssl_options = no_ticket, no_compression
tls_preempt_cipherlist = yes
smtpd_tls_auth_only = no
#postscreen_access_list = permit_mynetworks cidr:/etc/postfix/postscreen_access.cidr
#postscreen_blacklist_action = drop
EOF
  cat > '/etc/postfix/postscreen_access.cidr' << EOF
#permit my own IP addresses.
${myip}/32             permit
EOF
  cat > '/etc/aliases' << EOF
# See man 5 aliases for format
postmaster:    root
root:   ${mailuser}
EOF
  cat > '/etc/postfix/master.cf' << EOF
#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================
smtp      inet  n       -       y       -       -       smtpd
#smtp      inet  n       -       y       -       1       postscreen
smtpd     pass  -       -       y       -       -       smtpd
dnsblog   unix  -       -       y       -       0       dnsblog
tlsproxy  unix  -       -       y       -       0       tlsproxy
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
#628       inet  n       -       y       -       -       qmqpd
pickup    unix  n       -       y       60      1       pickup
cleanup   unix  n       -       y       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       y       1000?   1       tlsmgr
rewrite   unix  -       -       y       -       -       trivial-rewrite
bounce    unix  -       -       y       -       0       bounce
defer     unix  -       -       y       -       0       bounce
trace     unix  -       -       y       -       0       bounce
verify    unix  -       -       y       -       1       verify
flush     unix  n       -       y       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       y       -       -       smtp
relay     unix  -       -       y       -       -       smtp
        -o syslog_name=postfix/\$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       y       -       -       showq
error     unix  -       -       y       -       -       error
retry     unix  -       -       y       -       -       error
discard   unix  -       -       y       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       y       -       -       lmtp
anvil     unix  -       -       y       -       1       anvil
scache    unix  -       -       y       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about \${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
maildrop  unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail argv=/usr/bin/maildrop -d \${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  user=cyrus argv=/cyrus/bin/deliver -e -r \${sender} -m \${extension} \${user}
#
# ====================================================================
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m \${extension} \${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a\$sender - \$nexthop!rmail (\$recipient)
#
# Other external delivery methods.
#
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r \$nexthop (\$recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t\$nexthop -f\$sender \$recipient
scalemail-backend unix  - n n - 2 pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store \${nexthop} \${user} \${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
  \${nexthop} \${user}

policyd-spf  unix  -       n       n       -       0       spawn
    user=policyd-spf argv=/usr/bin/policyd-spf
EOF
newaliases
echo "/^Received: .*/     IGNORE" > /etc/postfix/smtp_header_checks
echo "/^User-Agent.*Roundcube Webmail/            IGNORE" >> /etc/postfix/smtp_header_checks
curl https://repo.dovecot.org/DOVECOT-REPO-GPG | gpg --import
gpg --export ED409DA1 > /etc/apt/trusted.gpg.d/dovecot.gpg
echo "deb https://repo.dovecot.org/ce-2.3-latest/${dist}/$(lsb_release -cs) $(lsb_release -cs) main" > /etc/apt/sources.list.d/dovecot.list
apt-get update
apt-get install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sieve -y
adduser dovecot mail
adduser netdata mail
systemctl enable dovecot
apt-get install spamassassin spamc spamass-milter -y
adduser debian-spamd mail
adduser spamass-milter mail
sed -i 's/CRON=0/CRON=1/' /etc/default/spamassassin
  cat > '/etc/default/spamass-milter' << EOF
# spamass-milt startup defaults

# OPTIONS are passed directly to spamass-milter.
# man spamass-milter for details

# Non-standard configuration notes:
# See README.Debian if you use the -x option with sendmail
# You should not pass the -d option in OPTIONS; use SOCKET for that.

# Default, use the spamass-milter user as the default user, ignore
# messages from localhost
OPTIONS="-u spamass-milter -i 127.0.0.1"

# Reject emails with spamassassin scores > 15.
OPTIONS="\${OPTIONS} -r 8"

# Do not modify Subject:, Content-Type: or body.
#OPTIONS="\${OPTIONS} -m"

######################################
# If /usr/sbin/postfix is executable, the following are set by
# default. You can override them by uncommenting and changing them
# here.
######################################
SOCKET="/var/spool/postfix/spamass/spamass.sock"
SOCKETOWNER="postfix:postfix"
SOCKETMODE="0660"
######################################
EOF
systemctl enable spamassassin
systemctl restart spamassassin
cd /usr/share/nginx/
mailver=$(curl -s "https://api.github.com/repos/roundcube/roundcubemail/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -d /usr/share/nginx/roundcubemail ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新roundcube中..." 7 68
    wget --no-check-certificate https://github.com/roundcube/roundcubemail/releases/download/${mailver}/roundcubemail-${mailver}-complete.tar.gz
    tar -xvf roundcubemail*.tar.gz
    rm -rf roundcubemail*.tar.gz
    cd /usr/share/nginx/roundcubemail-1.*/bin/
    ./installto.sh /usr/share/nginx/roundcubemail
    cd /usr/share/nginx/
    rm -rf /usr/share/nginx/roundcubemail-1.*
    cd /usr/share/nginx/roundcubemail
    php /usr/local/bin/composer update --no-dev
    chown -R nginx:nginx /usr/share/nginx/roundcubemail/
    rm -rf /usr/share/nginx/roundcubemail/installer/
  else
    wget --no-check-certificate https://github.com/roundcube/roundcubemail/releases/download/${mailver}/roundcubemail-${mailver}-complete.tar.gz
    tar -xvf roundcubemail-${mailver}-complete.tar.gz
    rm -rf roundcubemail-${mailver}-complete.tar.gz
    mv /usr/share/nginx/roundcubemail*/ /usr/share/nginx/roundcubemail/
    chown -R nginx:nginx /usr/share/nginx/roundcubemail/
    cd /usr/share/nginx/roundcubemail/
    curl -s https://getcomposer.org/installer | php
    cp -f composer.json-dist composer.json
    php /usr/local/bin/composer update --no-dev
    rm -rf /usr/share/nginx/roundcubemail/installer/
    cd
    mysql -u root -e "CREATE DATABASE roundcubemail DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "CREATE USER roundcube@localhost IDENTIFIED BY '${password1}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost;"
    mysql -u root -e "flush privileges;"
    mysql -u roundcube -p"${password1}" -D roundcubemail < /usr/share/nginx/roundcubemail/SQL/mysql.initial.sql  
fi
mkdir /usr/share/nginx/pgp/
deskey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_#&!*%?' | fold -w 24 | head -n 1)
  cat > '/usr/share/nginx/roundcubemail/config/config.inc.php' << EOF
<?php

\$config['language'] = 'zh_CN';
\$config['db_dsnw'] = 'mysql://roundcube:${password1}@unix(/run/mysqld/mysqld.sock)/roundcubemail';
\$config['default_host'] = '${domain}';
\$config['default_port'] = 143;
\$config['smtp_server'] = '127.0.0.1';
\$config['smtp_port'] = 25;
\$config['support_url'] = 'https://github.com/johnrosen1/vpstoolbox';
\$config['product_name'] = 'Roundcube Webmail For VPSTOOLBOX';
\$config['des_key'] = '${deskey}';
\$config['ip_check'] = true;
\$config['enable_installer'] = false;
\$config['identities_level'] = 3;

// ----------------------------------
// PLUGINS
// ----------------------------------
// List of active plugins (in plugins/ directory)
\$config['plugins'] = array('archive','emoticons','enigma','markasjunk','newmail_notifier','zipdownload');
\$config['newmail_notifier_basic'] = true;
\$config['newmail_notifier_desktop'] = true;
\$config['enigma_pgp_homedir'] = '/usr/share/nginx/pgp/';
\$config['enigma_encryption'] = true;
\$config['enigma_signatures'] = true;
\$config['enigma_decryption'] = true;
\$config['enigma_password_time'] = 5;
EOF

# sed -i '${domain} 127.0.0.1' /etc/hosts
# echo "${domain} 127.0.0.1" >> /etc/hosts

if grep -q "MAILTO" /etc/crontab
then
  :
else
echo 'MAILTO=""' >> /etc/crontab
fi

useradd -m -s /sbin/nologin ${mailuser}
echo -e "${password1}\n${password1}" | passwd ${mailuser}
apt-get install opendkim opendkim-tools -y
gpasswd -a postfix opendkim
  cat > '/etc/opendkim.conf' << EOF
Syslog      yes
UMask     007
Canonicalization  relaxed/simple
Mode      sv
SubDomains    no
AutoRestart         yes
AutoRestartRate     10/1M
Background          yes
DNSTimeout          5
SignatureAlgorithm  rsa-sha256
Socket    local:/var/spool/postfix/opendkim/opendkim.sock
PidFile               /var/run/opendkim/opendkim.pid
OversignHeaders   From
TrustAnchorFile       /usr/share/dns/root.key
UserID                opendkim
KeyTable           refile:/etc/opendkim/key.table
SigningTable       refile:/etc/opendkim/signing.table
ExternalIgnoreList  /etc/opendkim/trusted.hosts
InternalHosts       /etc/opendkim/trusted.hosts
Nameservers 127.0.0.1
EOF
  cat > '/etc/default/opendkim' << EOF
RUNDIR=/var/run/opendkim
SOCKET="local:/var/spool/postfix/opendkim/opendkim.sock"
USER=opendkim
GROUP=opendkim
PIDFILE=\$RUNDIR/\$NAME.pid
EXTRAAFTER=
EOF
mkdir /etc/opendkim/
mkdir /etc/opendkim/keys/
chown -R opendkim:opendkim /etc/opendkim
chmod go-rw /etc/opendkim/keys
echo "*@${domain}    default._domainkey.${domain}" > /etc/opendkim/signing.table
echo "default._domainkey.${domain}     ${domain}:default:/etc/opendkim/keys/${domain}/default.private" > /etc/opendkim/key.table
  cat > '/etc/opendkim/trusted.hosts' << EOF
127.0.0.1
localhost
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16

*.${domain}
EOF
mkdir /etc/opendkim/keys/${domain}/
opendkim-genkey -b 2048 -d ${domain} -D /etc/opendkim/keys/${domain} -s default -v
chown opendkim:opendkim /etc/opendkim/keys/${domain}/default.private
mkdir /var/spool/postfix/opendkim/
chown opendkim:postfix /var/spool/postfix/opendkim
systemctl restart opendkim
usermod -a -G dovecot netdata
usermod -a -G mail postfix
  cat > '/etc/dovecot/conf.d/10-auth.conf' << EOF
auth_username_format = %Ln
disable_plaintext_auth = no
auth_mechanisms = plain
!include auth-system.conf.ext
EOF
  cat > '/etc/dovecot/conf.d/10-ssl.conf' << EOF
ssl = required
ssl_cert = </etc/certs/${domain}_ecc/fullchain.cer
ssl_key = </etc/certs/${domain}_ecc/${domain}.key
#ssl_cipher_list = ${cipher_server}
ssl_min_protocol = TLSv1.2
ssl_prefer_server_ciphers = yes
ssl_options = no_ticket
EOF
  cat > '/etc/dovecot/conf.d/10-master.conf' << EOF
service imap-login {
  inet_listener imap {
    #port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
}

service submission-login {
  inet_listener submission {
    #port = 587
  }
}

service imap {
  # Most of the memory goes to mmap()ing files. You may need to increase this
  # limit if you have huge mailboxes.
  #vsz_limit = $default_vsz_limit

  # Max. number of IMAP processes (connections)
  #process_limit = 1024
}

service lmtp {
 unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
  }
}

service submission {
  # Max. number of SMTP Submission processes (connections)
  #process_limit = 1024
}

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }

}

service auth-worker {
  #user = root
}

service dict {
  unix_listener dict {
    #mode = 0600
    #user = 
    #group = 
  }
}

service stats {
  unix_listener stats {
    user = netdata
    group = netdata
    mode = 0666
  }
}
EOF
  cat > '/etc/dovecot/conf.d/10-mail.conf' << EOF

mail_location = maildir:~/Maildir

namespace inbox {
  inbox = yes
}

mail_privileged_group = mail

protocol !indexer-worker {
  #mail_vsize_bg_after_count = 0
}
EOF
  cat > '/etc/dovecot/conf.d/15-mailboxes.conf' << EOF
namespace inbox {
  mailbox Archive {
    auto = subscribe
    special_use = \Archive
  }
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
    autoexpunge = 14d
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
    autoexpunge = 14d
  }
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
}
EOF
  cat > '/etc/dovecot/conf.d/15-lda.conf' << EOF
protocol lda {
  # Space separated list of plugins to load (default is global mail_plugins).
  mail_plugins = \$mail_plugins sieve
}
EOF
  cat > '/etc/dovecot/conf.d/20-lmtp.conf' << EOF
protocol lmtp {
  # Space separated list of plugins to load (default is global mail_plugins).
  mail_plugins = \$mail_plugins quota sieve
}
EOF
  cat > '/etc/dovecot/conf.d/90-sieve.conf' << EOF
plugin {
  sieve = file:~/sieve;active=~/.dovecot.sieve
  sieve_before = /var/mail/SpamToJunk.sieve
}
EOF
  cat > '/var/mail/SpamToJunk.sieve' << EOF
require "fileinto";

if header :contains "X-Spam-Flag" "YES"
{
   fileinto "Junk";
   stop;
}
EOF
  cat > '/etc/fail2ban/filter.d/dovecot-pop3imap.conf' << EOF
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed|Aborted login \(\d+ authentication attempts).*rip=`<HOST>`
EOF

if grep -q "dovecot-pop3imap" /etc/fail2ban/jail.conf
then
:
else
echo "[dovecot-pop3imap]" >> /etc/fail2ban/jail.conf
echo "enabled = true" >> /etc/fail2ban/jail.conf
echo "filter = dovecot-pop3imap" >> /etc/fail2ban/jail.conf
echo "action = iptables-multiport[name=dovecot-pop3imap, port="pop3,imap", protocol=tcp]" >> /etc/fail2ban/jail.conf
echo "logpath = /var/log/mail.log" >> /etc/fail2ban/jail.conf
echo "maxretry = 8" >> /etc/fail2ban/jail.conf
echo "findtime = 1200" >> /etc/fail2ban/jail.conf
echo "bantime = 1200" >> /etc/fail2ban/jail.conf
fi
systemctl restart fail2ban
sievec /var/mail/SpamToJunk.sieve
chown -R mail:mail /var/mail/*
systemctl restart postfix dovecot
clear
}
