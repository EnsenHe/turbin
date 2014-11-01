#!/bin/sh
## install.sh for turbin in /home/winerzk/projects/turbin@eyston_z
## 
## Made by Antoine Favarel
## Login   <winerzk@epitech.net>
## 
## Started on  Sat Nov  1 12:20:48 2014 Antoine Favarel
## Last update Sat Nov  1 12:36:17 2014 Antoine Favarel
##

echo "Instalation de turbin.."
mkdir -p ~/tmp/
git clone https://github.com/EnsenHe/turbin.git ~/tmp/turbin/
sudo chmod 777 ~/tmp/turbin/turbin.rb
sudo chmod 777 ~/tmp/turbin/turbin_serv.rb
sudo mv ~/tmp/turbin/turbin.rb /usr/bin/turbin
sudo mv ~/tmp/turbin/turbin_serv.rb /usr/bin/turbin_serv.rb
rm ~/tmp/turbin -fr
echo "Instalation de turbin terminé"
echo "usage : turbin [start | stop]"