#!/bin/sh
## install.sh for turbin in /home/winerzk/projects/turbin@eyston_z
## 
## Made by Antoine Favarel
## Login   <winerzk@epitech.net>
## 
## Started on  Sat Nov  1 12:20:48 2014 Antoine Favarel
## Last update Sat Nov  1 12:49:48 2014 Antoine Favarel
##

echo "Instalation de turbin.."
rm -fr ~/tmp/turbin
mkdir -p ~/tmp/
git clone https://github.com/EnsenHe/turbin.git ~/tmp/turbin/
sudo rm -fr "/usr/bin/turbin"
sudo rm -fr "/usr/bin/turbin_serv.rb"
chmod 777 ~/tmp/turbin/turbin.rb
chmod 777 ~/tmp/turbin/turbin_serv.rb
user=$USER
sudo ln -s "/home/$user/tmp/turbin/turbin.rb" "/usr/bin/turbin"
sudo ln -s "/home/$user/tmp/turbin/turbin_serv.rb" "/usr/bin/turbin_serv.rb"
echo "Instalation de turbin terminé"
echo "usage : turbin [start | stop]"