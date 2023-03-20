#!/bin/bash

function send() {
  scp $1 pi@mrtr.local:/home/pi;
}

function copy() {
  ssh pi@mrtr.local "sudo cp -vv $1 $2";
}

if [ "$1" ]; then
  case "$1" in
    'passwd') stty -echo;
              echo -n "New password: ";
              read password;
              echo;
              echo -n "Retype new password: ";
              read vpasswd;
              echo;
              if [ "$password" = "$vpasswd" ]; then
                stty echo; 
                ssh pi@mrtr.local "echo pi:${password} | sudo chpasswd";
                if [ $? -eq 0 ]; then echo "Password changed succesfully"; fi
              else
                echo "Password not verified. Refuse to change.";
                exit 1;
              fi;;
    'netsum') ssh pi@mrtr.local "sudo /usr/local/bin/netsum -o stdout";;
    'openvpn') if [ "$2" ]; then
                  case "$2" in
                    'nodes') ssh pi@mrtr.local "wget -q https://vpn.morketsmerke.org/nodes.txt -O /tmp/vpn_nodes.txt; cat /tmp/vpn_nodes.txt;";;
                    'config') if [ "$3" ]; then
                                node=$3; 
                                if echo $node | grep -q '/etc/openvpn/client'; then
                                  node=$(basename $node);
                                fi
                              else 
                                help; exit 1; 
                              fi
                              if [ "$4" ]; then 
                                cacert=$4;
                                if echo $cacert | grep -q '/etc/openvpn/client'; then
                                  cacert=$(basename $cacert);
                                fi
                              else
                                help; exit 1;
                              fi
                              if [ "$5" ]; then 
                                certfile=$5;
                                if echo $certfile | grep -q '/etc/openvpn/client'; then
                                  certfile=$(basename $certfile);
                                fi 
                              else 
                                help; exit 1; 
                              fi
                              if [ "$6" ]; then 
                                keyfile=$6;
                                if echo $keyfile | grep -q '/etc/openvpn/client'; then
                                  keyfile=$(basename $keyfile);
                                fi
                              else
                                help; exit 1;
                              fi;
                              cat > /tmp/client.conf <<EOF
dev tun
client
remote $node
proto udp
port 17003
nobind
ca $cacert
cert $certfile
key $keyfile
verb 3
EOF
                              send /tmp/client.conf;
                              copy /home/pi/client.conf /etc/openvpn/client/client.conf;;
                    'connect') ssh pi@mrtr.local "sudo systemctl start openvpn.service";
                                echo "OpenVPN service is starting but"
                                echo "if you are using private key with password";
                                echo "(which is recommended), remeber";
                                echo "to execute: 'mrtr openvpn pkp' immediately";;
                    'certs') if [ "$3" ]; then
                              filename=$(basename $3);
                              send $3;
                              ssh pi@mrtr.local "sudo tar -xzvf /home/pi/$filename -C /etc/openvpn/client";
                             else
                              help;
                              exit 1;
                             fi;;
                    'pkp') echo "There is no echo, you are on your own. Good luck"; 
                          stty -echo;
                          ssh pi@mrtr.local "sudo systemd-tty-ask-password-agent";
                          stty echo;;
                    'route') ssh pi@mrtr.local "bash /usr/local/bin/openvpn-setroute";;
                  esac
                else
                  help;
                  exit 1;
               fi;;
    'wlan') if [ "$2" ]; then
              case $2 in
                'list') ssh pi@mrtr.local "sudo wlanconn list";;
                'connect') if [ "$4" ]; then
                            ssh pi@mrtr.local "sudo wlanconn \"$3\" $4";
                           else
                            ssh pi@mrtr.local "sudo wlanconn \"$3\"";
                           fi;;
              esac
            else
              help;
              exit 1;
            fi;;
    'shell') ssh pi@mrtr.local;;
    'reboot') ssh pi@mrtr.local "sudo reboot";;
    'poweroff') ssh pi@mrtr.local "sudo poweroff";;         
  esac
else
  help;
  exit 1;
fi
