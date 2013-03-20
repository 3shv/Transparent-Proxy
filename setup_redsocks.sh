#!/bin/bash
# Originally written by przemoc.net. 
# First modified and shared by Rajesh Veeankani. This is a clone.
# Modified by Dilawar. 
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
package=redsocks
if [ $? -eq 0 ]
        then echo -e "$package install succeeded\n"
          rm -rf darkk*
          rm redsocks.zip
        else 
	echo -e "$package install failed..exiting!\n"
	exit 1
fi
clear
echo -e "\nConfiguring redscoks.conf file.."
echo -e "\n|- Please enter your credentials when prompted\n"
read -p "  + Enter LDAP username:" username
stty -echo
read -p "  + Enter LDAP Password:" pass
stty echo
redsocks_conf_set(){
touch redsocks.conf

echo "base {
 log_debug = on;
 log_info = on;
 log = \"file:/tmp/redsock.log\";
 daemon = on;
 //user = $USER;
 //group = redsocks;
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
// This is the ip of netmon.iitb.ac.in
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
}" > $HOME/.redsocks.conf
}

redsocks_conf_set 
sudo groupadd -f redsocks
sudo usermod -a -G redsocks $USER

if [ -f $HOME/.redsocks.conf ];
then 
  echo "Configuration file .redsocks.conf is created in your home folder."
else 
  echo "Configuration failed. Existing..."
  exit
fi 

