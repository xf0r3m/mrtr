#!/bin/bash

# WLAN as WAN
# ETH as LAN (192.168.4.1/24)
# dnsmasq (as dhcp server and dns cache)
# hostapd (just installed)
# SSH (opened only on ETH)
# iptables (for drop policy and NAT)
# add pi user with sudo without password

sudo apt update;
sudo apt upgrade -y;

sudo apt install dnsmasq hostapd iptables netfilter-persistent iptables-persistent -y;

echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf;
echo -e "\tstatic ip_address=192.168.4.1/24" | sudo tee -a /etc/dhcpcd.conf;
echo | sudo tee -a /etc/dhcpcd.conf;
echo "nohook wpa_supplicant" | sudo tee -a /etc/dhcpcd.conf;
sudo systemctl stop wpa_supplicant.service;
sudo systemctl disable wpa_suplicant.service;

echo "interface=eth0" | sudo tee /etc/dnsmasq.conf;
echo "dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,12h" | sudo tee -a /etc/dnsmasq.conf;
echo "dhcp-option=3,192.168.4.1" | sudo tee -a /etc/dnsnasq.conf;
echo "dhcp-option=6,192.168.4.1" | sudo tee -a  /etc/dnsmasq.conf;

sudo systemctl restart dnsmasq.service;
sudo systemctl status dnsmasq.service --no-pager;

sudo useradd -m -s /bin/bash pi
echo "pi:rasp83rry" | chpasswd;
echo "pi ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers;

sudo mkdir /etc/wlanconn;
sudo groupadd wlanconn;
sudo chown root:wlanconn /etc/wlanconn;
sudo chmod 775 /etc/wlanconn;
sudo usermod -aG wlanconn pi;

defaultListenAddressLine=$(grep '^#ListenAddress\ 0\.0\.0\.0' /etc/ssh/sshd_config);
newListenAddressLine="ListenAddress 192.168.4.1";
sudo sed -i "s/${defaultListenAddressLine}/${newListenAddressLine}/" /etc/ssh/sshd_config;

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/mrtr.conf;

sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE;
sudo iptables -A INPUT -i wlan0 -p udp -j DROP;
sudo iptables -A INPUT -i wlan0 -p tcp --syn -j DROP;
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 67 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 17003 -j ACCEPT;

sudo netfilter-persistent save;

sudo apt install git -y;
cd;
git clone https://github.com/xf0r3m/mrtr;
sudo cp -vv ~/mrtr/netsum /usr/local/bin;
sudo cp -vv ~/mrtr/netsum_service /usr/local/bin;
sudo cp -vv ~/mrtr/wlansum.sh /usr/local/bin/wlansum;
sudo cp -vv ~/mrtr/wlanconn.sh /usr/local/bin/wlanconn;
sudo chmod +x /usr/local/bin/*;
sudo cp ~/mrtr/netsum.service /etc/systemd/system;
sudo systemctl enable netsum.service;
rm -rf ~/mrtr;

cd;
git clone https://github.com/goodtft/LCD-show.git;
cd LCD-show;
sudo ./LCD35-show;


