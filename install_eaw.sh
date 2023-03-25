#!/bin/bash

# ETH as WAN
# WLAN as LAN (192.168.4.1/24)
# dnsmasq (as dhcp server and dns cache)
# hostapd (mrtr_DD:EE:FF)
# SSH 
# iptables (for ACCEPT policy with DROP rules and NAT)
# add pi user with sudo without password

sudo apt update;
sudo apt upgrade -y;

sudo apt install dnsmasq hostapd iptables netfilter-persistent iptables-persistent openvpn whois -y;
sudo systemctl stop openvpn.service;
sudo systemctl disable openvpn.service;
sudo systemctl disable systemd-rfkill;
sudo systemctl mask systemd-rfkill;
sudo apt purge -y rfkill*;

echo "interface wlan0" | sudo tee /etc/dhcpcd.conf;
echo -e "\tstatic ip_address=192.168.4.1/24" | sudo tee -a /etc/dhcpcd.conf;
echo -e "\tnohook wpa_supplicant" | sudo tee -a /etc/dhcpcd.conf;
sudo systemctl stop wpa_supplicant.service;
sudo systemctl disable wpa_suplicant.service;

echo "interface=wlan0" | sudo tee /etc/dnsmasq.conf;
echo "dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,12h" | sudo tee -a /etc/dnsmasq.conf;
echo "dhcp-option=3,192.168.4.1" | sudo tee -a /etc/dnsnasq.conf;
echo "dhcp-option=6,192.168.4.1" | sudo tee -a  /etc/dnsmasq.conf;

sudo systemctl restart dnsmasq.service;
sudo systemctl status dnsmasq.service --no-pager;

sudo useradd -m -s /bin/bash pi
echo "pi:rasp83rry" | sudo chpasswd;
echo "pi ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers;

sudo hostnamectl set-hostname mrtr;
sudo sed -i 's/raspberrypi/mrtr/g' /etc/hosts

wlanId=$(ip addr show wlan0 | grep 'ether' | awk '{printf $2}' | cut -d ":" -f4-6 | sed 's/://g')

cat >> hostapd.conf << EOF
country_code=PL
interface=wlan0
ssid=mrtr_${wlanId}
hw_mode=g
channel=$(((RANDOM % 13) + 1))
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=rasp83rry
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

sudo cp hostapd.conf /etc/hostapd

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/mrtr.conf;

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE;
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 67 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 17003 -j ACCEPT;
sudo iptables -A INPUT -i eth0 -p udp -j DROP;
sudo iptables -A INPUT -i eth0 -p tcp --syn -j DROP;

sudo netfilter-persistent save;

sudo apt install git -y;
cd;
git clone https://github.com/xf0r3m/mrtr;
sudo cp -vv ~/mrtr/netsum /usr/local/bin;
sudo cp -vv ~/mrtr/netsum_service /usr/local/bin;
sudo cp -vv ~/mrtr/openvpn-setroute /usr/local/bin/openvpn-setroute;
sudo chmod +x /usr/local/bin/*;
sudo cp ~/mrtr/netsum.service /etc/systemd/system;
sudo cp ~/mrtr/openvpn.service /etc/systemd/system;
sudo systemctl daemon-reload;
sudo systemctl enable netsum.service;
rm -rf ~/mrtr;

cd;
git clone https://github.com/goodtft/LCD-show.git;
cd LCD-show;
sudo ./LCD35-show;


