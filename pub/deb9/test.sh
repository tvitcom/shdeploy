#!/bin/sh

mysql_secure_installation <<EOF
n
test123
test123
y
y
y
y
y
EOF
echo "Secure mysql installation is done!!!"