shdeploy
========

This application with golang simple web file-server for hosting text configuration files, bash scripts and other file for deploy linux environment for developers. Also in 'pub/deb9/' placed the preseed file for autonomous Debian9 amd64 installation with preconfigured passwords for root and mysql server. You may rename '_preseed' to 'preseed' then edit appropriate root and user passwords and use it. 
Now it ready for Debian 9/10, Ubuntu 16/18 systems for amd64 compatible processors only. 

to Debian 9 environment with next useful packages for everyday developers need: 
- [x] SSH server (on port 12222)
- [x] Common: 7z, sqlite3, mysql-workbench, meld, google-chrome
- [ ] Skype
- [x] Git, Svn, Vim
- [x] Sublime-Text && Sublime-Merge - awesome tools:)
- [x] LAMP stack with PhpMyAdmin
- [x] VirtualBox additional autoinstallation with inserted iso
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] Python3, pip3 and venv
- [x] Docker, Docker-Compose
- [x] Kubernetis (kubectl)
- [x] google cloud sdk

to Debian 10 environment with next useful packages for everyday developers need: 
- [x] SSH server (on port 12222)
- [x] Common: 7z, sqlite3, mysql-workbench, meld, google-chrome
- [x] Skype
- [x] Git, Svn, Vim
- [x] Sublime-Text && Sublime-Merge - awesome tools:)
- [x] LAMP stack with PhpMyAdmin
- [x] VirtualBox additional autoinstallation with inserted iso
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] Python3, pip3 and venv
- [x] Docker, Docker-Compose
- [x] Kubernetis (kubectl)
- [x] google cloud sdk

to Google Cloud instance with Debian 10 environment: 
- [x] SSH server (default condition)
- [x] Common: 7z, sqlite3
- [ ] !!!No desktop software
- [x] Git, Svn, Vim
- [ ] !!! Absent developer tools
- [ ] !!! Without LAMP stack
- [ ] !!! No VirtualBoxes
- [x] Golang 1.14.8 environment
- [x] NodeJS and NPM of nodejs 12.x version
- [x] Python3, pip3 and venv
- [ ] !!! No Docker, Docker-Compose
- [ ] !!! Kubernetis (kubectl)
- [ ] !!! google cloud sdk

Also to Ubuntu 16/18 environment with next useful packages for everyday developers need: 
- [x] SSH server (on port 12222)
- [x] Common: 7z, sqlite3, mysql-workbench, meld, google-chrome
- [x] Skype
- [x] Git, Svn, Vim
- [x] sublime-text && sublime-merge - awesome tools:)
- [x] LAMP stack with PhpMyAdmin
- [x] Golang 1.13 environment
- [x] NodeJS and NPM of nodejs 12.x version
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

Using wget (*for example deploy-host with 192.168.10.100) start software deploy:

```bash
# For Debian 9:
wget http://192.168.10.100:3000/deb9/install.sh && sh install.sh
# For Debian 10:
wget http://192.168.10.100:3000/deb10/install.sh && sh install.sh
## OR for Ubuntu 16:
wget http://192.168.10.100:3000/u16/install.sh && sh install.sh
## OR for Ubuntu 18:
wget http://192.168.10.100:3000/u18/install.sh && sh install.sh
```

NOTICE: 
-------
i. For VBoxLinuxAdditional you will mount the disk and install before the deployment process.
