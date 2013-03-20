Transparent-Proxy
=================

This is a fork of Rajesh Veeranki work. But it is greatly influenced by http://przemoc.net/tips/linux#making_socks_proxy_transparent 

USAGE 
=====

1. Install iptables-persistent, and libevent
2. Execute ./configure.sh and follow the steps.
3. If you can use firefox without filling in the proxy information then you
   should add ./iptables.sh to your startup programs. See the question on how to
   do it on ubuntu :

   http://askubuntu.com/questions/814/how-to-run-scripts-on-start-up

4. Do not set this on server. It sets-up transparent proxies system-wide. Anyone
   logged on to your system will be able to use it. If you can restrict access
   to individual users then let me know.
