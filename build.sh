#!/bin/sh
cd $HOME/MyStuff/mysite && zola build && rsync -auP public/* root@dhruvcodes.me:/var/www/mysite
git add .
git commit -m 'Automated Commit'
git push origin master

