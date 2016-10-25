#! /bin/zsh

hexo clean
hexo generate
cd public #到生产的博客的目录

git init
git add .
git commit -m "update at `date` "

git remote add coding git@git.coding.net:ourui/ourui.git >> /dev/null 2>&1
echo "### Pushing Pages to Coding..."
git push coding master:coding-pages -f

git remote add origin git@github.com:ourui/ourui.github.com.git >> /dev/null 2>&1
echo "### Pushing Pages to Github..."
git push origin master:master -f

echo "### Done"


cd ..
echo "### Backup Source to Coding..."
git push coding master:source -f

echo "### Backup Source to Github..."
git push origin master:source -f

echo "### Done"




