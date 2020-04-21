#!/bin/sh

## Define from ENV file like this
#PROJECT_DIR=$(basename $(pwd))
#CURR_DIR=$(pwd)"/"
#CONFIG_DIR=$CURR_DIR"public/deb9/"
#REMOTE_DIR="/home/a/Go/src/my.localhost/funny/"$PROJECT_DIR"/"
. $(pwd)"/.DEPLOY-CONFIG"

## Prepare configs directory
cd $CURR_DIR"pub/deb9"
tar czf delivered-conf.tar.gz delivered-conf
cd $CURR_DIR"pub/u16"
tar czf delivered-conf.tar.gz delivered-conf
cd $CURR_DIR"pub/u18"
tar czf delivered-conf.tar.gz delivered-conf


rsync -e 'ssh -p 12222' -PLSluvr --exclude=".git" --exclude=".gitignore" --del --no-perms --no-t $CURR_DIR a@192.168.10.100:$REMOTE_DIR

## clean
rm $CURR_DIR"pub/deb9/delivered-conf.tar.gz"
rm $CURR_DIR"pub/u16/delivered-conf.tar.gz"
rm $CURR_DIR"pub/u18/delivered-conf.tar.gz"

echo "Deployed to webserver installation host: Ok!"
exit 100
