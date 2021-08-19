#!/bin/sh
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

