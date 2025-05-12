#!/bin/bash
export CGO_ENABLED=0
go install go.k6.io/xk6/cmd/xk6@v0.11.0
xk6 build --with github.com/szkiba/xk6-faker@v0.3.0 --with github.com/mstoykov/xk6-counter@v0.0.1 --with github.com/grafana/xk6-exec@v0.3.0 --with github.com/avitalique/xk6-file@v1.4.0
cat /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json.dist >/"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
sed -i "s/http/https/" /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
sed -i "s/localhost/$WEBSITE_URL/" /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
sed -i "s/3000/443/" /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
sed -i "s/Continuous-Deployment-Header-Name/aws-cf-cd-$CLOUDFRONT_HEADER/" /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
sed -i "s/continuous-deployment-header-value/$CLOUDFRONT_HEADER/" /"$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
