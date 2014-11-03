#!/bin/sh
## install.sh for turbin in /home/winerzk/projects/turbin@eyston_z
## 
## Made by Antoine Favarel
## Login   <winerzk@epitech.net>
## 
## Started on  Sat Nov  1 12:20:48 2014 Antoine Favarel
## Last update Mon Nov  3 13:38:25 2014 Antoine Favarel
##

echo "Instalation de turbin.."
rm -fr ~/tmp/turbin
mkdir -p ~/tmp/
git clone https://github.com/EnsenHe/turbin.git ~/tmp/turbin/
sudo rm -fr "/usr/bin/turbin"
chmod 777 ~/tmp/turbin/turbin.rb
user=$USER
sudo ln -s "/home/$user/tmp/turbin/turbin.rb" "/usr/bin/turbin"
echo "Instalation de turbin terminé"
echo "usage : turbin [start | stop]"