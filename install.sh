#!/bin/sh
## install.sh for turbin in /home/winerzk/projects/turbin@eyston_z
## 
## Made by Antoine Favarel
## Login   <winerzk@epitech.net>
## 
## Started on  Sat Nov  1 12:20:48 2014 Antoine Favarel
## Last update Sat Nov  1 12:29:58 2014 Antoine Favarel
##

echo "Instalation de turbin.."
mkdir -p ~/bin/
git clone https://github.com/EnsenHe/turbin.git ~/bin/turbin/
sudo chmod +x ~/bin/turbin/turbin.rb
sudo chmod +x ~/bin/turbin/turbin_serv.rb
sudo ln -s ~/bin/turbin/turbin.rb /usr/bin/turbin
echo "Instalation de turbin terminé"
echo "usage : turbin [start | stop]"