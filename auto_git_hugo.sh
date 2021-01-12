#!/bin/bash
git add *
git commit -am "modificaciones"
git push
hugo -D
cd public
cp -r * /home/celiagm/github/app_static/hugo_netlify_site/public /home/celiagm/github/app_static/unbitdeinformacioncadadia
cd /home/celiagm/github/app_static/unbitdeinformacioncadadia
git add *
git commit -m "commit automatico"
git pull
git push
