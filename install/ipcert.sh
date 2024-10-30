#!/usr/bin/env bash

## ip-cert 模组

set +e

ip_issue(){

mkdir /var/local/zerossl
mkdir /etc/certs/${myip}_ecc/
cd /var/local/zerossl
curl --retry 5 -LO https://github.com/tinkernels/zerossl-ip-cert/releases/download/v0.5.2/zerossl-ip-cert-linux-amd64.tar.gz
tar -xvf zerossl*.gz
rm *.gz
cd /var/local/zerossl/zerossl-ip-cert-linux-amd64
  cat > '/var/local/zerossl/zerossl-ip-cert-linux-amd64/config.yml' << EOF
dataDir: /var/local/zerossl # Data directory for containing the status and temporary files
logFile: /var/local/zerossl/log.txt # Log file
cleanUnfinished: true # Clean zerossl certificates that are not finished issuing.
certConfigs:
  # Use confId to identify the certificate configuration
  - commonName: ${myip}
    # mandatory
    confId: xx1
    # your zerossl api key
    apiKey: ${zerossl_api}
    ######## CSR INFO ########
    # country: US
    # province: CA
    # city: San Francisco
    # locality: San Francisco
    # organization: Earth
    # organizationUnit: Development
    ######## CSR INFO ########
    # certificate validity in days
    days: 90
    # key type, ecdsa or rsa
    keyType: ecdsa
    # rsa key bits
    keyBits: 2048
    # ecdsa curve, P-256 or P-384
    keyCurve: P-256
    # signature algorithm, ECDSA-SHA256 or SHA256-RSA or ECDSA-SHA384 or SHA384-RSA
    sigAlg: ECDSA-SHA256
    # fixed
    strictDomains: 1
    # fixed
    verifyMethod: HTTP_CSR_HASH
    # verify hook executable, will be called before verifying domains
    verifyHook: /var/local/zerossl/verify-hook.sh
    # post hook executable, will be called after certificates arrival
    postHook: /var/local/zerossl/post-hook.sh
    # certificate store path
    certFile: /etc/certs/${domain}_ecc/fullchain.cer
    # key store path
    keyFile: /etc/certs/${domain}_ecc/${domain}.key
EOF
  cat > '/var/local/zerossl/verify-hook.sh' << "EOF"
#!/usr/bin/env bash

echo "nginx verify hook running"

echo "ZEROSSL_HTTP_FV_HOST: $ZEROSSL_HTTP_FV_HOST"
echo "ZEROSSL_HTTP_FV_PATH: $ZEROSSL_HTTP_FV_PATH"
echo "ZEROSSL_HTTP_FV_PORT: $ZEROSSL_HTTP_FV_PORT"
echo "ZEROSSL_HTTP_FV_CONTENT: $ZEROSSL_HTTP_FV_CONTENT"

nginx_bin=$(which nginx)
echo "nginx_bin: $nginx_bin"

file_content=$(echo "$ZEROSSL_HTTP_FV_CONTENT" | tr -d '\r' | awk '{printf "%s\\n", $0}')
echo "file_content: $file_content"

echo "server {" > /etc/nginx/conf.d/verify.conf
echo "    listen 80 fastopen=512 reuseport default_server;" >> /etc/nginx/conf.d/verify.conf
echo "    listen [::]:80 fastopen=512 reuseport default_server;" >> /etc/nginx/conf.d/verify.conf
echo "    location $ZEROSSL_HTTP_FV_PATH {" >> /etc/nginx/conf.d/verify.conf
echo "        return 200 '$file_content';" >> /etc/nginx/conf.d/verify.conf
echo "    }" >> /etc/nginx/conf.d/verify.conf
echo "    location /.well-known/acme-challenge/ {" >> /etc/nginx/conf.d/verify.conf
echo "      root /usr/share/nginx/;" >> /etc/nginx/conf.d/verify.conf
echo "    }" >> /etc/nginx/conf.d/verify.conf
echo "    location / {" >> /etc/nginx/conf.d/verify.conf
echo "    return 301 https://\$host\$request_uri;" >> /etc/nginx/conf.d/verify.conf
echo "    }" >> /etc/nginx/conf.d/verify.conf
echo "}" >> /etc/nginx/conf.d/verify.conf

nginx -s reload
EOF

  cat > '/var/local/zerossl/post-hook.sh' << "EOF"
#!/usr/bin/env bash

systemctl restart trojan postfix dovecot nginx hysteria || true
EOF

chmod +x /var/local/zerossl/zerossl-ip-cert-linux-amd64/zerossl-ip-cert
chmod +x /var/local/zerossl/verify-hook.sh
chmod +x /var/local/zerossl/post-hook.sh

echo "" > /etc/nginx/conf.d/default.conf
/var/local/zerossl/zerossl-ip-cert-linux-amd64/zerossl-ip-cert -config /var/local/zerossl/zerossl-ip-cert-linux-amd64/config.yml

  if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    :
    else
    colorEcho ${ERROR} "请访问 https://app.zerossl.com/developer 检查api是否正确"
    exit 1
  fi
  chmod +r /etc/certs/${domain}_ecc/fullchain.cer
  chmod +r /etc/certs/${domain}_ecc/${domain}.key

crontab -l > mycron
echo "0 0 * * * /var/local/zerossl/zerossl-ip-cert-linux-amd64/zerossl-ip-cert -renew -config /var/local/zerossl/zerossl-ip-cert-linux-amd64/config.yml" >> mycron
crontab mycron
rm mycron

}