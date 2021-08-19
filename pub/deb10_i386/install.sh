#!/bin/sh
##
## Only for Debian 10 amd64 system
##

## configuration (Shoul be in the header scripts anyway!!!)

SET_HOSTNAME="deb10"
REGULAR_USER="a"
MYSQL_PASS="L;bycs_"$(hostname)
GOLANG_VER="1.14.11"
REMOTE_DEPLOY_ENDPOINT="http://192.168.43.100:3000/"
REMOTE_DEPLOY_PATH="deb10/"
REMOTE_CONF="delivered-conf"
REMOTE_CONF_FILE=$REMOTE_CONF".tar.gz"

## validation of current user

if [ $(id -u) != "0" ];then
   echo "You must be root to do this." 2>&1
   exit 100
fi

## init from /root only

cd /root

## bootstrap of config

if ! [ -d ~/delivered-conf ] || ! [ -f ~/delivered-conf/ssh/id_rsa.pub ];then
    echo "The delivered-conf is not valid"
    exit 100
fi

## apt

apt-get clean
mv /etc/apt/sources.list /etc/apt/sources.list-original
cp -f ~/delivered-conf/sources.list /etc/apt

apt-get -y purge bluez bluetooth
apt-get -y purge popularity-contest
apt-get clean && apt-get update && apt-get -y upgrade
apt-get -y install ufw sudo curl


## ssh

if ! [ -f /etc/ssh/sshd_config ];then
  apt-get -y install openssh-server
fi

if ! [ -f /etc/ssh/sshd_config-original ];then
  mv /etc/ssh/sshd_config /etc/ssh/sshd_config-original
  cp ~/delivered-conf/sshd_config /etc/ssh/
  chmod 644 /etc/ssh/sshd_config
fi

if ! [ -d /root/.ssh ];then
  mkdir -m 700 /root/.ssh
fi

if ! [ -d /home/$REGULAR_USER/.ssh ];then
  mkdir -m 700 /home/$REGULAR_USER/.ssh
fi

if [ -f ~/.ssh/authorized_keys ];then
  cat ~/delivered-conf/ssh/id_rsa.pub >> ~/.ssh/authorized_keys
else
  cat ~/delivered-conf/ssh/id_rsa.pub > ~/.ssh/authorized_keys
fi

# ssh key for user

if [ -f /home/$REGULAR_USER/.ssh/authorized_keys ];then
  cat ~/delivered-conf/ssh/id_rsa.pub >> /home/$REGULAR_USER/.ssh/authorized_keys
else
  cat ~/delivered-conf/ssh/id_rsa.pub > /home/$REGULAR_USER/.ssh/authorized_keys
fi
systemctl restart ssh
cp -r ~/.ssh /home/$REGULAR_USER
chmod 700 /home/$REGULAR_USER/.ssh
chmod 600 /home/$REGULAR_USER/.ssh/authorized_keys
chown -R $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.ssh

## Desktop developer soft

apt-get -y install meld filezilla chromium searchmonkey

## sublime-text && sublime-merge

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
apt-get -y install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt-get -y install sublime-text sublime-merge

## google-chrome

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get -y install ./google-chrome-stable_current_amd64.deb

## command developer soft

apt-get -y install gcc make linux-headers-amd64
apt-get -y install exuberant-ctags
apt-get -y install sqlite3 libsqlite3-dev subversion

## Install and configure git

apt-get -y install dirmngr --install-recommends
apt-get -y install software-properties-common
apt-get -y install git-core git-svn tig

git config --global core.autocrlf input
git config --global core.safecrlf false
git config --global core.filemode false
git config --global core.whitespace -trailing-space,-space-before-tab,-indent-with-non-tab
git config --global color.diff.meta 'blue black bold'
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.bl blame
git config --global alias.l "log --oneline --graph"
git config --global alias.last 'log -1 HEAD'

if [ -f /home/$REGULAR_USER/.bash_aliases ];then
	mv /home/$REGULAR_USER/.bash_aliases /home/$REGULAR_USER/.bash_aliases-original
fi
if [ -f /root/.bash_aliases ];then
	mv /root/.bash_aliases /root/.bash_aliases-original
fi
cp -f ~/delivered-conf/.bash_aliases /home/$REGULAR_USER
chmod 644 /home/$REGULAR_USER/.bash_aliases
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.bash_aliases
cp -f ~/delivered-conf/.bash_aliases /root
chmod 644 /home/$REGULAR_USER/.bash_aliases
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.bash_aliases

## lamp

apt-get -y install ca-certificates
apt-get -y install apache2 libxml2-dev icu-devtools libicu-dev libxml2-dev
apt-get -y install php php-mysql libapache2-mod-php
apt-get -y install php-mbstring php7.3-xdebug php-cgi
apt-get -y install php7.3-curl php7.3-soap
apt-get -y install php-xml php-zip php-fpm php-gd php-memcache php-pgsql php-readline
apt-get -y install php-intl php-bcmath php7.3-opcache 
apt-get -y install libmcrypt-dev
apt-get -y install php-dev
# apt-get -y install libmcrypt-dev php-pear
# pecl channel-update pecl.php.net
#!!! You should add "extension=mcrypt.so" to appropriates php.ini files
phpenmod opcache mbstring intl
a2enmod ssl rewrite headers expires

cp /etc/hosts /etc/hosts-original
cat ~/delivered-conf/_hosts >> /etc/hosts
mv /var/www /var/www.original
mkdir -p -m 777 /var/WWW/pma
tar xzf ~/delivered-conf/pma-approot.tar.gz
mv approot /var/WWW/pma/approot
chmod 777 /var/WWW
chmod 644 /var/WWW/pma/approot/config.inc.php

mv /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf-original
cp ~/delivered-conf/conf-available/security.conf /etc/apache2/conf-available/
chmod 644 /etc/apache2/apache2.conf
chown root:root /etc/apache2/apache2.conf
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf-original
cp ~/delivered-conf/apache2.conf /etc/apache2
chmod 644 /etc/apache2/apache2.conf
chown root:root /etc/apache2/apache2.conf
mv /etc/apache2/sites-available /etc/apache2/sites-available-original
cp -r ~/delivered-conf/sites-available /etc/apache2
chmod 755 /etc/apache2/sites-available
chown root:root  /etc/apache2/sites-available
chmod 644 /etc/apache2/sites-available/*.conf
chown root:root  /etc/apache2/sites-available/*.conf

mv /etc/php/7.3/apache2/php.ini /etc/php/7.0/apache2/php.ini-original
mv /etc/php/7.7.3/cli/php.ini /etc/php/7.3/cli/php.ini-original
mv /etc/php/7.7.3/cli/php.ini /etc/php/7.3/cgi/php.ini-original
mv /etc/php/7.7.3/cli/php.ini /etc/php/7.3/fpm/php.ini-original

cp -f ~/delivered-conf/php/7.3/apache2/php.ini /etc/php/7.3/apache2/
chmod 644 /etc/php/7.3/apache2/php.ini
chown root:root /etc/php/7.3/apache2/php.ini

cp -f ~/delivered-conf/php/7.3/cli/php.ini /etc/php/7.3/cli/
chmod 644 /etc/php/7.3/cli/php.ini
chown root:root /etc/php/7.3/cli/php.ini

cp -f ~/delivered-conf/php/7.3/cgi/php.ini /etc/php/7.3/cgi/
chmod 644 /etc/php/7.3/cgi/php.ini
chown root:root /etc/php/7.3/cgi/php.ini

cp -f ~/delivered-conf/php/7.3/fpm/php.ini /etc/php/7.3/fpm/
chmod 644 /etc/php/7.3/fpm/php.ini
chown root:root /etc/php/7.3/fpm/php.ini

a2ensite /etc/apache2/sites-available/pma.conf
systemctl restart apache2

## mysqld

apt-get -y install mariadb-server mariadb-client mariadb-common
mv /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf-original
mv ~/delivered-conf/50-server.cnf /etc/mysql/mariadb.conf.d
chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf
chown root:root /etc/mysql/mariadb.conf.d/50-server.cnf

mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${MYSQL_PASS}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
  FLUSH PRIVILEGES;
_EOF_
systemctl restart mysql

apt-get -y install -f && apt-get -y autoremove && apt-get -y clean
. /root/.bashrc
rm /root/$REMOTE_CONF_FILE
rm -rf /root/$REMOTE_CONF
echo "DEPLOYED: Ok!"
