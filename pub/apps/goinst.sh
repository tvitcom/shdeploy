#!/bin/bash

## Run firstly as:
## $~ sh goinst.sh

VERS="1.16.7"

ARCHIT=`dpkg --print-architecture`;
[ "$ARCHIT" = "amd64" ] || ARCHIT="386";

if [ ! -d "$HOME/go$VERS" ];then
	wget https://dl.google.com/go/go$VERS.linux-$ARCHIT.tar.gz;
	tar xzf go$VERS.linux-$ARCHIT.tar.gz;
	mv go go$VERS;
	rm go$VERS.linux-$ARCHIT.tar.gz;
fi;

if [ -z $GOPATH ]; then
	echo "Строка GOPATH сейчас пуста. Запишем конфигурации в .bashrc"
	echo ' ' >> $HOME/.bashrc;
	echo '## go exports:' >> $HOME/.bashrc;
	echo 'export GOROOT=$HOME/go'$VERS >> $HOME/.bashrc;
	echo 'export GOPATH=$HOME/Go' >> $HOME/.bashrc;
	echo 'export GOTMPDIR="/tmp"' >> $HOME/.bashrc;
	echo 'export GOARCH='$ARCHIT >> $HOME/.bashrc;
	echo 'export GOOS=linux;' >> $HOME/.bashrc;
	echo 'export PATH=$PATH:$GOROOT/bin;' >> $HOME/.bashrc;
	echo 'export PATH=$PATH:$GOPATH/bin;' >> $HOME/.bashrc;
	echo ' ' >> $HOME/.bashrc;
	echo '## github fig for golang env:' >> $HOME/.bashrc;
	echo 'XDG_CONFIG_HOME=$HOME/.config' >> $HOME/.bashrc;
	echo 'XDG_DATA_HOME=$HOME/.local/share' >> $HOME/.bashrc;
fi

mkdir -m 777 -p $HOME/Go;
echo "Golang $VERS успешно установлен.";
echo "Выполните команды:";
echo ". .bashrc";
echo "go get -u golang.org/x/tools/cmd/godoc";
echo "go version";
echo "go install golang.org/x/website/tour@latest";
echo "Можете запустить интерактивный тур по языку командой:";
echo "tour";
exit;

