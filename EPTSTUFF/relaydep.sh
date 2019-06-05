
#!/bin/bash

sudo apt install git -y
sudo apt install python-pip -y
sudo apt install tmux -y
sudo git clone https://github.com/SecureAuthCorp/impacket
sudo git clone https://github.com/fox-it/mitm6
sudo git clone https://github.com/lgandx/Responder
sudo cd impacket && pip install . && cd .. 
sudo apt-get install python-impacket python-twisted python-netifaces python-ipaddress python-scapy python-future -y

