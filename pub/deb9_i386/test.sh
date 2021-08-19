#!/bin/sh

### input db|project name:
read  -p "Select alias (sort of projectname) of db,username: " ALIAS

# for local user:
# mysql --user=root <<_EOF_
# CREATE USER '${ALIAS}'@'localhost' IDENTIFIED BY 'pass_to_${ALIAS}';
# CREATE DATABASE IF NOT EXISTS ${ALIAS};
# GRANT USAGE ON * . * TO '${ALIAS}'@'localhost' IDENTIFIED BY 'pass_to_${ALIAS}' WITH MAX_CONNECTIONS_PER_HOUR 0 
# MAX_USER_CONNECTIONS 0 MAX_QUERIES_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
# GRANT ALL PRIVILEGES ON ''.* TO '${ALIAS}'@'localhost';
# _EOF_

# for network user:
mysql --user=root -p <<_EOF_
CREATE USER '${ALIAS}'@'%' IDENTIFIED BY 'pass_to_${ALIAS}';
GRANT USAGE ON *.* TO '${ALIAS}'@'%' IDENTIFIED BY 'pass_to_${ALIAS}' REQUIRE NONE 
WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS `${ALIAS}`;
GRANT ALL PRIVILEGES ON `${ALIAS}`.* TO '${ALIAS}'@'%';
_EOF_

if [ $? -ne 0];then
    echo "Database and user: "$ALIAS" with password: pass_to_${ALIAS} is created: Ok";
else
    echo "Rised some errors!: fail"
fi
