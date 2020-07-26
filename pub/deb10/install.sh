#!/bin/sh
##
## Only for Debian 10 amd64 system
##

## configuration

SET_HOSTNAME="deb10"
REGULAR_USER="a"
MYSQL_PASS="L;bycs_"$(hostname)
GOLANG_VER="1.14.6"
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

wget $REMOTE_DEPLOY_ENDPOINT$REMOTE_DEPLOY_PATH$REMOTE_CONF_FILE -O $REMOTE_CONF_FILE
tar xzf $REMOTE_CONF_FILE

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
apt-get clean && apt-get update && apt-get upgrade
apt-get -y install ufw sudo curl # fix with absent curl


## ssh

if ! [ -f /etc/ssh/sshd_config ];then
	apt-get -y install openssh-server
fi

if ! [ -f /etc/ssh/sshd_config-original ];then
	mv /etc/ssh/sshd_config /etc/ssh/sshd_config-original
fi
cp ~/delivered-conf/sshd_config /etc/ssh/
chmod 644 /etc/ssh/sshd_config

if ! [ -d /root/.ssh ];then
	mkdir -m 600 /root/.ssh
fi

if ! [ -d /home/$REGULAR_USER/.ssh ];then
	mkdir -m 600 /home/$REGULAR_USER/.ssh
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
chmod 600 /home/$REGULAR_USER/.ssh
chown -R $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.ssh

# ufw

ufw enable && ufw default deny && ufw allow 12222/tcp

# sudo

gpasswd -a $REGULAR_USER sudo
echo $REGULAR_USER"	ALL=(ALL:ALL)	ALL" >> /etc/sudoers
chmod 750 /home/$REGULAR_USER

## common soft

mv /home/$REGULAR_USER/.bashrc /home/$REGULAR_USER/.bashrc-original
cp ~/delivered-conf/.bashrc /home/$REGULAR_USER
chmod 644 /home/$REGULAR_USER/.bashrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.bashrc
cp -f ~/delivered-conf/.vimrc /home/$REGULAR_USER
chmod 766 /home/$REGULAR_USER/.vimrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.vimrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.vimrc
cp -f ~/delivered-conf/.vimrc /root
chmod 766 /root/.vimrc
cp -rf ~/delivered-conf/.vim /root
cp -rf ~/delivered-conf/.vim /home/$REGULAR_USER
chmod 766 /home/$REGULAR_USER/.vim

apt-get -y install p7zip-full
apt-get -y install apt-transport-https 

## Install user soft

#apt-get -y purge smplayer lxmusic #mpv
#apt-get -y install cryptsetup desktop-file-utils
#apt-get -y install vim-gtk
#apt-get -y install vlc thunderbird gparted audacity

## Desktop developer soft

apt-get -y install meld filezilla chromium searchmonkey
wget https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.21-1ubuntu18.04_amd64.deb
apt-get -y install gdebi-core gdebi
gdebi -n mysql-workbench*amd64.deb
apt --fix-broken install && apt autoremove -y 

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

apt-get install -y dirmngr --install-recommends
apt-get install -y software-properties-common
apt-get install -y git-core git-svn tig

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

## virtual box additional

apt-get upgrade
apt-get -y install build-essential module-assistant dkms

is_vboxmounted() {
  blkid | grep VBOXADDITIONS > /dev/null 2>&1
}

mountvbox() {
  mount -t iso9660 /dev/sr0 /media/cdrom0 > /dev/null 2>&1
}

vboxaddition_installer_ready() {
  	ls /media/sdrom0 | grep VBoxLinuxAdditions.run > /dev/null 2>&1
}

vboxaddition_installed() {
	cat /etc/group | grep vboxsf > /dev/null 2>&1
}

if [ is_vboxmounted ] && [ mountvbox ] && [ vboxaddition_installer_ready ];then
	sh /media/cdrom0/VBox*.run
	echo "VBoxLinuxAdditions.run succesfully start: OK!"
fi
if [ vboxaddition_installed ];then
	/sbin/adduser $REGULAR_USER vboxsf
	echo "Group vboxsf added for user: OK!"
fi

## lamp

apt-get -y install ca-certificates
apt-get -y install apache2 libxml2-dev icu-devtools libicu-dev libxml2-dev
apt-get -y install php php-mysql libapache2-mod-php
apt-get -y install php-mbstring php7.3-xdebug php-cgi
apt-get -y install php7.3-curl php7.3-soap
apt-get -y install php-xml php-zip php-fpm php-gd php-memcache php-pgsql php-readline
apt-get -y install php-intl php-bcmath php7.3-opcache 
apt-get -y install libmcrypt-dev
apt-get -y install php-dev libmcrypt-dev php-pear
pecl channel-update pecl.php.net
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

## golang

mkdir -m 777 -p /home/$REGULAR_USER/Go/src/my.localhost/funny/
mkdir -m 777 -p /home/$REGULAR_USER/.local/share

wget "https://dl.google.com/go/go"$GOLANG_VER".linux-amd64.tar.gz"
tar xzf "go"$GOLANG_VER".linux-amd64.tar.gz"

echo '## go exports:' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOROOT=$HOME/go'$GOLANG_VER >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOPATH=$HOME/Go' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOBIN=$GOROOT/bin' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOTMPDIR="/tmp"' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOARCH=amd64;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOOS=linux;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export PATH=$PATH:$GOROOT/bin;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export PATH=$PATH:$GOPATH/bin;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'go get -u golang.org/x/tools/cmd/godoc' >> "/home/"$REGULAR_USER"/.bashrc"

echo '\n' >> "/home/"$REGULAR_USER"/.bashrc"
echo '## github fig for golang env:' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'XDG_CONFIG_HOME=$HOME/.config' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'XDG_DATA_HOME=$HOME/.local/share' >> "/home/"$REGULAR_USER"/.bashrc"

mv go "/home/"$REGULAR_USER"/go"$GOLANG_VER
chmod -R 777 /home/$REGULAR_USER/Go
chmod -R 777 "/home/"$REGULAR_USER"/go"$GOLANG_VER

## nodejs

curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get update && apt-get install -y nodejs npm

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get install --no-install-recommends yarn

## python3

apt-get update && apt-get upgrade && apt-get -y install python3-venv

cp -f ~/delivered-conf/.pyrc /home/$REGULAR_USER
cp -f ~/delivered-conf/.pyrc /root
chmod 644 /home/$REGULAR_USER/.pyrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.pyrc

## JupiterNotebook

apt-get -y install python3-pip python3-dev

## docker and docker-compose

apt-get -y install gnupg2
# curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update && apt-get -y install docker.io
/sbin/usermod -aG docker $REGULAR_USER

curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker_installed() {
	docker --version | grep build
}
docker_compose_installed() {
	docker-compose --version | grep build
}
if [ docker_installed ] && [ docker_compose_installed ];then
	echo "Docker-CE and Docker-compose installed: Ok!";
fi

## Kubernetis

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

kubectl_ready() {
  kubectl version --client | grep "BuildDate" > /dev/null 2>&1
}

if [ kubectl_ready ] ;then
	echo "kubectl installed: Ok!"
fi

# google cloud sdk
# wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-289.0.0-linux-x86_64.tar.gz
# tar czf google-cloud-sdk-289.0.0-linux-x86_64.tar.gz $$ rm google-cloud-sdk-289.0.0-linux-x86_64.tar.gz
# cd google-cloud-sdk-289.0.0-linux-x86_64
# ./google-cloud-sdk/install.sh
# ./google-cloud-sdk/bin/gcloud init

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#OR: echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#OR: curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update && apt-get install google-cloud-sdk

## TODO:tenzorflow

## TODO:dlib

## finalise

apt-get -y install -f && apt-get -y autoremove && apt-get clean
. /root/.bashrc
rm /root/$REMOTE_CONF_FILE
rm -rf /root/$REMOTE_CONF
echo "DEPLOYED: Ok!"
