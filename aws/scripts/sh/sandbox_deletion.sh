#!/bin/bash
BUCKET_NAME="$PROJECT_NAME-$BRANCH_NAME"
echo "Deleting Bucket: $BUCKET_NAME..."
aws s3 rm s3://$BUCKET_NAME --recursive --region $AWS_DEFAULT_REGION
aws s3api delete-bucket --bucket $BUCKET_NAME --region $AWS_DEFAULT_REGION
echo "Bucket $BUCKET_NAME was successfully deleted."