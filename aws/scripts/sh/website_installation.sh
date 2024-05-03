echo #### Install Software
n install 21.7.1
git clone -b $WEBSITE_GIT_REPOSITORY_BRANCH "$WEBSITE_GIT_REPOSITORY_LINK.git" ~/website
cd /root/website/
echo #### Install pnpm
npm install -g pnpm
echo #### Install dependencies
pnpm i --frozen-lockfile
