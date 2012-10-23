#!/bin/bash
echo "Executing the script..."
wget -O redsocks.zip https://github.com/darkk/redsocks/zipball/master
if [ $? -eq 0 ]
        then echo -e "File downloaded\n"
        else 
	echo -e "Download failed..exiting!\n"
	exit 1
fi
unzip redsocks.zip 
cd darkk-redsocks-*/
echo -e "Installing libevent-dev package\n"
package=libevent-dev
sudo apt-get install libevent-dev
if [ $? -eq 0 ]
        then echo -e "$package install succeeded\n"
        else 
	echo -e "$package install failed..exiting!\n"
	exit 1
fi
clear
echo -e "Compiling redsocks\n"
make
sudo cp ./redsocks /usr/local/sbin/redsocks
sudo apt-get install redsocks
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
 log_debug = off;
 log_info = off;
 log = \"stderr\";
 daemon = on;\
 user = redsocks;
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
}" > tmp.txt
sudo cp tmp.txt /etc/redsocks.conf
rm tmp.txt
}
redirect_rules_set(){
touch redirect.rules
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
chmod +x ./redirect.rules
sudo iptables-restore ./redirect.rules
}
redsocks_conf_set
sudo sed -i 's/no/yes/g' /etc/default/redsocks
sudo sed -i 's.DAEMON=/usr.DAEMON=/usr/local.g' /etc/init.d/redsocks
redirect_rules_set
clear
echo -e "\nPress yes whenever asked from here onwards\n"
sudo apt-get install iptables-persistent
echo -e "\nStarting redsocks redirctor\n"
sudo service redsocks start
echo -e "\nFinished...\n "
cd ..
rm -rf darkk-redsocks-*/
rm -rf redsocks.zip
