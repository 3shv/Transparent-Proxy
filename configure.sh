#!/bin/bash
./setup_redsocks.sh 
sudo ./start_trasparent_proxy.sh iptables 
./start_trasparent_proxy.sh 
