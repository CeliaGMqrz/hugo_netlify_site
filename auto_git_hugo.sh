#!/bin/bash

hugo -D
cd public
cp -r * /home/celiagm/github/app_estatica_hugo/hugo_netlify_site/public /home/celiagm/github/app_estatica_hugo/unbitdeinformacioncadadia
cd /home/celiagm/github/app_estatica_hugo/unbitdeinformacioncadadia
git add *
git commit -m "commit automatico"
git pull
git push
