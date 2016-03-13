#! /bin/zsh

hexo clean
hexo generate
cd public

git init
git add .
git commit -m "update at `date` "

git remote add coding git@git.coding.net:ourui/ourui.git >> /dev/null 2>&1
echo "### Pushing Pages to Coding..."
git push coding master:coding-pages -f

cd ..
echo "### Backup Source to Coding..."
git push coding master:source 

echo "### Done"


git remote add origin git@github.com:ourui/ourui.github.com.git >> /dev/null 2>&1
echo "### Pushing to Github..."
git push origin master:master -f
echo "### Done"

