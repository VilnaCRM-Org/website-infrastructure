chmod +x ~
chown -R codebuild-user:codebuild-user /codebuild-user/website
chown -R codebuild-user:codebuild-user $CODEBUILD_SRC_DIR
chown -R codebuild-user:codebuild-user /usr/local/lib/node_modules/
