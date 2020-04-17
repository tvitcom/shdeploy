shdeploy
========

This application with golang simple web file-server for hosting text configuration files, bash scripts and other file for deploy linux environment for developers. Also in 'pub/deb9/' placed the preseed file for autonomous Debian9 amd64 installation with preconfigured passwords for root and mysql server. You may rename '_preseed' to 'preseed' then edit appropriate root and user passwords and use it. 
Now it ready for Debian 9 system in virtual box containers.

The shdeploy will deliver environment with next useful pachages ready for everyday developers need:

- [x] Common: Git, Svn, 7z, sqlite3, mysql-workbench, meld
- [x] LAMP stack with PhpMyAdmin
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] VirtualBox Additional some sharing settings
- [x] Python3 and venv
- [x] Docker, Docker-Compose
- [x] Kubernetis (kubectl)
- [ ] tenzorflow 
- [ ] dlib

For use it you will set variables in the:

 1) .REMOTE_CONFIG file
 2) in header of pub/deb9/install.sh
 3) pub/deb/_preseed file and rename it as preseed for autoinstallation Debian 9 in VirtualBox
 4) make own ssh rsa-key files and plase id_rsa.pub in pub/deb9/delivered-conf/ssh
 5) set appropriate port without myown 12222 in pub/deb9/delivered-conf/sshd_config

On the web-server deployment host with golang environment:

 ```bash
 go run fileserver.go
```
Or any other appropriate web-server like apache2, nginx, etc with hosted public /pub directory as webroot condition.

On target server with installed curl in terminal you will run:

```bash
su root
curl http://192.168.10.100:3000/deb9/install.sh | sh
```

Or without curl (for example deploy-host with 192.168.10.100):

```bash
wget http://192.168.10.100:3000/deb9/install.sh && sh install.sh
```

NOTICE: 
-------
i. For VBoxLinuxAdditional you will mount the disk before deployment process.
