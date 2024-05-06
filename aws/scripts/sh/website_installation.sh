echo #### Install Software
n install 21.7.1
git clone -b $WEBSITE_GIT_REPOSITORY_BRANCH "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website
cd /codebuild-user/website/
echo #### Install pnpm
npm install -g pnpm
echo #### Install dependencies
pnpm i --frozen-lockfile
chmod +x ~
chown -R codebuild-user:codebuild-user /codebuild-user/website
chown -R codebuild-user:codebuild-user $CODEBUILD_SRC_DIR
chown -R codebuild-user:codebuild-user /usr/local/lib/node_modules/
