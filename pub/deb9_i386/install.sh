#!/bin/sh
##
## Only for Debian 9 amd64 system
##

## configuration

REGULAR_USER="a"
MYSQL_PASS="L;bycs_"$(hostname)
GOLANG_VER="1.14.13"
GOLANG_PLATFORM="386" #Or: "amd64"
REMOTE_DEPLOY_ENDPOINT="http://192.168.10.100:3000/"
REMOTE_DEPLOY_PATH="deb9/"
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

# wget $REMOTE_DEPLOY_ENDPOINT$REMOTE_DEPLOY_PATH$REMOTE_CONF_FILE -O $REMOTE_CONF_FILE
# tar xzf $REMOTE_CONF_FILE

if ! [ -d ~/delivered-conf ] || ! [ -f ~/delivered-conf/ssh/id_rsa.pub ];then
    echo "The delivered-conf is not valid"
    exit 100
fi

## apt

apt-get clean
mv /etc/apt/sources.list /etc/apt/sources.list-original
cp -f ~/delivered-conf/sources.list /etc/apt
apt-get update
apt-get -y purge bluez bluetooth sudo
apt-get -y purge popularity-contest
apt-get clean && apt-get update && apt-get -y upgrade
apt-get -y install ufw 
# apt-get -y install sudo curl # fix with absent curl


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
service ssh restart
cp -r ~/.ssh /home/$REGULAR_USER
chmod 700 /home/$REGULAR_USER/.ssh
chmod 600 /home/$REGULAR_USER/.ssh/authorized_keys
chown -R $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.ssh

# ufw

ufw enable && ufw default deny 
# && ufw allow 12222/tcp

# sudo

usermod -aG sudo $REGULAR_USER
echo $REGULAR_USER"	ALL=(ALL:ALL)	ALL" >> /etc/sudoers
chmod 750 /home/$REGULAR_USER

## common soft

mv /root/.bashrc /root/.bashrc-original
cp ~/delivered-conf/.bashrc.root /root/.bashrc
chmod 644 /root/.bashrc
cp -f ~/delivered-conf/.bash_aliases /root/.bash_aliases
chmod 644 /root/.bash_aliases
mv /home/$REGULAR_USER/.bashrc /home/$REGULAR_USER/.bashrc-original
cp ~/delivered-conf/.bashrc /home/$REGULAR_USER
chmod 644 /home/$REGULAR_USER/.bashrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.bashrc
cp -f ~/delivered-conf/.vimrc /home/$REGULAR_USER
chmod 766 /home/$REGULAR_USER/.vimrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.vimrc
cp -f ~/delivered-conf/.vimrc /root
chmod 766 /root/.vimrc
cp -rf ~/delivered-conf/.vim /root
cp -rf ~/delivered-conf/.vim /home/$REGULAR_USER
chmod 766 /home/$REGULAR_USER/.vim

apt-get -y install p7zip-full curl vim
apt-get -y install apt-transport-https 

## Install user soft

#apt-get -y purge smplayer lxmusic #mpv
#apt-get -y install cryptsetup desktop-file-utils
#apt-get -y install vim-gtk
#apt-get -y install vlc thunderbird gparted audacity

## Desktop developer soft

apt-get -y install meld
apt-get -y install mysql-workbench
apt-get -y install filezilla chromium

## sublime-text && sublime-merge

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt-get install sublime-text

## google-chrom

## command developer soft

apt-get -y install gcc make
# apt-get -y install linux-headers-amd64
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

## virtual box additional

## lamp

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
service mysql restart

## golang
mkdir -m 777 -p /home/$REGULAR_USER/Go/src/my.localhost/funny/
mkdir -m 777 -p /home/$REGULAR_USER/.local/share

wget "https://dl.google.com/go/go"$GOLANG_VER".linux-"$GOLANG_PLATFORM".tar.gz"
tar xzf "go"$GOLANG_VER".linux-"$GOLANG_PLATFORM".tar.gz"

echo '\n' >> "/home/"$REGULAR_USER"/.bashrc"
echo '## go exports:' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOROOT=$HOME/go'$GOLANG_VER >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOPATH=$HOME/Go' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOTMPDIR="/tmp"' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOARCH='$GOLANG_PLATFORM';' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export GOOS=linux;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export PATH=$PATH:$GOROOT/bin;' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'export PATH=$PATH:$GOPATH/bin;' >> "/home/"$REGULAR_USER"/.bashrc"
echo '#go get -u golang.org/x/tools/cmd/godoc' >> "/home/"$REGULAR_USER"/.bashrc"
echo '#go get -u github.com/golang/dep/cmd/dep' >> "/home/"$REGULAR_USER"/.bashrc"

echo '\n' >> "/home/"$REGULAR_USER"/.bashrc"
echo '## github fig for golang env:' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'XDG_CONFIG_HOME=$HOME/.config' >> "/home/"$REGULAR_USER"/.bashrc"
echo 'XDG_DATA_HOME=$HOME/.local/share' >> "/home/"$REGULAR_USER"/.bashrc"

mv go "/home/"$REGULAR_USER"/go"$GOLANG_VER
chmod -R 777 /home/$REGULAR_USER/Go
chmod -R 777 "/home/"$REGULAR_USER"/go"$GOLANG_VER

## nodejs

## python3

apt-get -y install python3-dev
apt-get -y install python3-pip
apt-get -y install python3-venv
cp -f ~/delivered-conf/.pyrc /home/$REGULAR_USER
cp -f ~/delivered-conf/.pyrc /root
chmod 644 /home/$REGULAR_USER/.pyrc
chown $REGULAR_USER:$REGULAR_USER /home/$REGULAR_USER/.pyrc

## JupiterNotebook

echo "PATH=$PATH:/home/"$REGULAR_USER"/.local/bin" >> /home/$REGULAR_USER/.bashrc
python3 -m pip install setuptools --upgrade

## docker and docker-compose

## Kubernetis

# google cloud sdk

# wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-289.0.0-linux-x86_64.tar.gz
# tar czf google-cloud-sdk-289.0.0-linux-x86_64.tar.gz $$ rm google-cloud-sdk-289.0.0-linux-x86_64.tar.gz
# cd google-cloud-sdk-289.0.0-linux-x86_64
# ./google-cloud-sdk/install.sh
# ./google-cloud-sdk/bin/gcloud init

## TODO:tenzorflow

## TODO:dlib

## finalise

apt-get -y install -f && apt-get -y autoremove && apt-get clean
. /root/.bashrc
rm /root/$REMOTE_CONF_FILE
rm -rf /root/$REMOTE_CONF
echo "DEPLOYED: Ok!"
