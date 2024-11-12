echo #### Install Software
n install ${NODE_VERSION:?Node.js version is not set}
n ${NODE_VERSION:?Node.js version is not set}
git clone -b $WEBSITE_GIT_REPOSITORY_BRANCH "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website
cd /codebuild-user/website/
echo #### Install pnpm
npm install -g pnpm
echo #### Install dependencies
make install
