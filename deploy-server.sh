#!/bin/sh

## Define from ENV file like this
# PROJECT_DIR=$(basename $(pwd))
# LOCAL_DIR=$(pwd)"/"
# REMOTE_DIR="/funny/"$PROJECT_DIR"/"
# REMOTE_USER="xxxx"
# REMOTE_PORT="xxxx"
# REMOTE_HOST="192.168.xxx.xxx"
. $(pwd)"/DEPLOY.CONF"

## Prepare configs directory
cd $LOCAL_DIR"pub/deb9"
tar czf delivered-conf.tar.gz delivered-conf
cd $LOCAL_DIR"pub/deb10"
tar czf delivered-conf.tar.gz delivered-conf
cd $LOCAL_DIR"pub/u16"
tar czf delivered-conf.tar.gz delivered-conf
cd $LOCAL_DIR"pub/u18"
tar czf delivered-conf.tar.gz delivered-conf


rsync -e "ssh -p $REMOTE_PORT" -PLSluvr \
	--exclude=".git" --exclude=".gitignore" --exclude="uploaded" \
	--del --no-perms --no-t \
	$LOCAL_DIR $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR

## clean
rm $LOCAL_DIR"pub/deb9/delivered-conf.tar.gz"
rm $LOCAL_DIR"pub/deb10/delivered-conf.tar.gz"
rm $LOCAL_DIR"pub/u16/delivered-conf.tar.gz"
rm $LOCAL_DIR"pub/u18/delivered-conf.tar.gz"

echo "Deployed to webserver installation host: Ok!"
exit 100
