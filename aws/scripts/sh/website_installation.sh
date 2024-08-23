echo #### Install Software
n install 20.14.0
n 20.14.0
git clone -b $WEBSITE_GIT_REPOSITORY_BRANCH "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website
cd /codebuild-user/website/
echo #### Install pnpm
npm install -g pnpm
echo #### Install dependencies
make install
