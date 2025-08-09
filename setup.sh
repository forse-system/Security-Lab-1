#!/bin/bash

sudo apt-get update -y
sudo apt-get install netplan.io -y

# Configure DNS via netplan first
sudo bash -c 'cat > /etc/netplan/01-dns.yaml << EOF
network:
  version: 2
  ethernets:
    "*":
      nameservers:
        addresses: [8.8.8.8]
      dhcp4-overrides:
        use-dns: false
EOF'

sudo netplan apply

# Now install other packages with proper DNS resolution
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo apt-get install dnsutils -y

sudo bash -c 'mkdir -p /etc/systemd/resolved.conf.d && printf "[Resolve]\nDNSStubListener=no\n" > /etc/systemd/resolved.conf.d/no-stub.conf && systemctl restart systemd-resolved'
sudo sh -c 'H=$(hostname -s); F=$(hostname -f 2>/dev/null || echo "$H.localdomain"); \
grep -qE "^127\.0\.1\.1[[:space:]]+$H(\s|$)" /etc/hosts || \
echo "127.0.1.1 $H $F" >> /etc/hosts'
