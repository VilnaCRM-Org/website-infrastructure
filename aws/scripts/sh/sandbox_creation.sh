#!/bin/bash

set -e

if [ "$IS_PULL_REQUEST" -eq 1 ]; then
    echo "Creating Bucket..."
    aws s3api create-bucket --bucket "$PROJECT_NAME-$BRANCH_NAME" --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to create bucket."
       exit 1
   fi
    aws s3api put-public-access-block --bucket "$PROJECT_NAME-$BRANCH_NAME" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" --region "$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to configure public access block."
       exit 1
   fi
    aws s3api put-bucket-ownership-controls --bucket "$PROJECT_NAME-$BRANCH_NAME" --ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]" --region "$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to configure bucket ownership controls."
       exit 1
   fi
    aws s3api put-bucket-acl --bucket "$PROJECT_NAME-$BRANCH_NAME" --acl public-read --region "$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to configure bucket ACL."
       exit 1
   fi
    aws s3api put-bucket-website --bucket "$PROJECT_NAME-$BRANCH_NAME" --website-configuration file://website_configuration.json --region "$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to configure static website hosting."
       exit 1
   fi
    aws s3api put-bucket-policy --bucket "$PROJECT_NAME-$BRANCH_NAME" --policy file://s3_policy.json --region "$AWS_DEFAULT_REGION"
   if [ $? -ne 0 ]; then
       echo "Error: Failed to configure bucket policy."
       exit 1
   fi
    echo "Bucket was successfully created."
fi
