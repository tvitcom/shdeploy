shdeploy
========

This application with golang simple web file-server for hosting text configuration files, bash scripts and other file for deploy linux environment for developers. Also in 'pub/deb9/' placed the preseed file for autonomous Debian9 amd64 installation with preconfigured passwords for root and mysql server. You may rename '_preseed' to 'preseed' then edit appropriate root and user passwords and use it. 
Now it ready for Debian 9, Ubuntu 16 and Ubuntu 18 systems in virtual box guest containers. 

to Debian 9 environment with next useful packages for everyday developers need: 
- [x] SSH server (on port 12222)
- [x] Common: Git, Svn
- [x] Common: 7z, sqlite3, mysql-workbench, meld, google-chrome
- [X] Sublime-Text && Sublime-Merge - awesome tools:)
- [x] LAMP stack with PhpMyAdmin
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] VirtualBox Guest linux additional support
- [x] Python3, pip3 and venv
- [x] Docker, Docker-Compose
- [x] Kubernetis (kubectl)
- [x] google cloud sdk

Also to Ubuntu 16 environment with next useful packages for everyday developers need: 
- [x] SSH server (on port 12222)
- [x] Common: 7z, sqlite3, mysql-workbench, meld, google-chrome
- [x] Common: Git, Svn
- [x] sublime-text && sublime-merge - awesome tools:)
- [x] LAMP stack with PhpMyAdmin
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] VirtualBox Guest linux additional support
- [x] Python3, pip3 and venv
- [x] Docker, Docker-Compose
- [x] Kubernetis (kubectl)
- [x] google cloud sdk

For use it you will set variables in the:

 1) .REMOTE_CONFIG file
 2) in header of pub/deb9/install.sh and in pub/u16/install.sh
 3) pub/deb/_preseed file and rename it as preseed for autoinstallation Debian 9 in VirtualBox
 4) make own ssh rsa-key files and plase id_rsa.pub in pub/deb9/delivered-conf/ssh, pub/u16/delivered-conf/ssh
 5) set appropriate port without myown 12222 in pub/deb9/delivered-conf/sshd_config and pub/u16/delivered-conf/sshd_config

On the web-server deployment host with golang environment:

 ```bash
 go run fileserver.go
```
Or any other appropriate web-server like apache2, nginx, etc with hosted public /pub directory as webroot condition.

On target server with installed curl in terminal you will run:

```bash
su root
# for Debian 9:
curl http://192.168.10.100:3000/deb9/install.sh | sh
# Or for Ubuntu 16/18:
curl http://192.168.10.100:3000/u16/install.sh | sh
```

Or without curl use wget (for example deploy-host with 192.168.10.100):

```bash
# For Debian 9:
wget http://192.168.10.100:3000/deb9/install.sh && sh install.sh
## OR for Ubuntu 16/18:
wget http://192.168.10.100:3000/deb9/install.sh && sh install.sh
```

NOTICE: 
-------
i. For VBoxLinuxAdditional you will mount the disk and install before the deployment process.
