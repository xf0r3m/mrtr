#!/bin/bash

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
                ssh pi@raspberrypi.local "echo pi:${password} | sudo chpasswd";
                if [ $? -eq 0 ]; then echo "Password changed succesfully"; fi
              else
                echo "Password not verified. Refuse to change.";
                exit 1;
              fi;;
    'netsum') ssh pi@raspberrypi.local "sudo /usr/local/bin/netsum -o stdout";;
    'openvpn') if [ "$2" ]; then
                  case "$2" in
                    'nodes') ssh pi@raspberrypi.local "wget -q https://vpn.morketsmerke.org/nodes.txt -O /tmp/vpn_nodes.txt; cat /tmp/vpn_nodes.txt;";;
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
                  esac
                else
                  help;
                  exit 1;
               fi;;
               
  esac
else
  help;
  exit 1;
fi
