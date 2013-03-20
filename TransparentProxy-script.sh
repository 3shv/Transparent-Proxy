#!/bin/bash
echo "Executing the script..."
if [ ! -f ./redsocks.zip ];
then 
  wget -O redsocks.zip https://github.com/darkk/redsocks/zipball/master
  if [ $? -eq 0 ]
          then echo -e "File downloaded\n"
          else 
    echo -e "Download failed..exiting!\n"
    exit 1
  fi
fi 
unzip -f -O redsocks.zip 
cd darkk-redsocks-*/
clear
echo -e "Compiling redsocks\n"
make
sudo cp ./redsocks /usr/local/sbin/redsocks
sudo cp ./debian/init.d /etc/init.d/redsocks
sudo cp ./debian/redsocks.default /etc/default/redsocks
sudo chmod +x /etc/init.d/redsocks
package=redsocks
if [ $? -eq 0 ]
        then echo -e "$package install succeeded\n"
        else 
	echo -e "$package install failed..exiting!\n"
	exit 1
fi
clear
echo -e "\nConfiguring redscoks.conf file..Please enter your credentials when prompted\n"
read -p "Enter LDAP username:" username
stty -echo
read -p "Enter LDAP Password:" pass
stty echo
redsocks_conf_set(){
touch redsocks.conf
echo "base {
 log_debug = on;
 log_info = on;
 log = \"stderr\";
 daemon = on;\
 user = dilawar;
 group = redsocks;
 redirector = iptables;
}
redsocks {
 /* 'local_ip' defaults to 127.0.0.1 for security reasons,
 * use 0.0.0.0 if you want to listen on every interface.
 * 'local_*' are used as port to redirect to.
 */
 local_ip = 127.0.0.1;
 local_port = 5123;
// 'ip' and 'port' are IP and tcp-port of proxy-server
 ip = 10.201.13.50;
 port = 80;
// known types: socks4, socks5, http-connect, http-relay
 type = http-relay;
login = \"$username\";
 password = \"$pass\";
}
redsocks {
 local_ip = 127.0.0.1;
 local_port = 5124;
ip = 10.201.13.50;
 port = 80;
type = http-connect;
login = \"$username\";
 password = \"$pass\";
}" > ~/.redsocks.conf
sudo cp ~/.redsocks.conf /etc/redsocks.conf
}

if [ -f ~/.redsocks.conf ];
then 
  echo "Configuration file .redsocks.conf is created in your home folder."
else 
  echo "Configuration failed. Existing..."
  exit
fi 

redirect_rules_set(){
touch redirect.rules
# This is from http://pritambaral.com/2012/04/transparent-proxy-on-linux/
echo "*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A OUTPUT -d 10.0.0.0/8 -j RETURN
-A OUTPUT -d 127.0.0.0/8 -j RETURN
-A OUTPUT -d 192.168.0.0/16 -j RETURN
-A OUTPUT -o eth0 -p tcp -m tcp --dport 80 -j DNAT --to-destination 127.0.0.1:5123
-A OUTPUT -o eth0 -p tcp -m tcp --dport 443 -j DNAT --to-destination 127.0.0.1:5124
-A OUTPUT -o wlan0 -p tcp -m tcp --dport 80 -j DNAT --to-destination 127.0.0.1:5123
-A OUTPUT -o wlan0 -p tcp -m tcp --dport 443 -j DNAT --to-destination 127.0.0.1:5124
COMMIT" > redirect.rules
sudo iptables-restore < redirect.rules
}
redsocks_conf_set
redirect_rules_set
clear
echo -e "\nPress yes whenever asked from here onwards\n"
echo -e "\nStarting redsocks redirctor\n"
sudo /usr/local/sbin/redsocks -c ~/.redsocks.conf
echo -e "\nDO NOT SET-UP IT ON A SHARED MACHINE. IT SETS THE PROXY SYSTEM WIDE.\n"
echo -e "\nFinished...\n "
cd ..
