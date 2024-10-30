#!/usr/bin/env bash

## Fail2ban模组 Fail2ban moudle

set +e

install_fail2ban() {
    apt-get install fail2ban -y
    if grep -q "DebianBanner" /etc/ssh/sshd_config; then
        :
    else
        ssh-keygen -A
        sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
        #sed -i 's/^HostKey \/etc\/ssh\/ssh_host_\(dsa\|ecdsa\)_key$/\#HostKey \/etc\/ssh\/ssh_host_\1_key/g' /etc/ssh/sshd_config
        #sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
        #sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
        sed -i 's/#PermitTunnel no/PermitTunnel no/' /etc/ssh/sshd_config
        #sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        #sed -i 's/#GatewayPorts no/GatewayPorts no/' /etc/ssh/sshd_config
        #sed -i 's/#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
        sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config
        sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
        echo "" >>/etc/ssh/sshd_config
        #echo "Protocol 2" >> /etc/ssh/sshd_config
        echo "DebianBanner no" >>/etc/ssh/sshd_config
        #echo "AllowStreamLocalForwarding no" >> /etc/ssh/sshd_config
        systemctl reload sshd
    fi
}
