#! /bin/zsh

hexo clean
hexo generate
cd public

git init
git add .
git commit -m "update at `date` "

git remote add origin git@github.com:ourui/ourui.github.com.git >> /dev/null 2>&1
echo "### Pushing to Github..."
git push origin master:master -f
echo "### Done"

git remote add gitcafe_ourui git@gitcafe.com:ourui/ourui.git >> /dev/null 2>&1
echo "### Pushing Pages to GitCafe..."
git push gitcafe_ourui master:gitcafe-pages -f


cd ..
echo "### Backup Source to GitCafe..."
git push gitcafe_ourui master:source 


echo "### Done"