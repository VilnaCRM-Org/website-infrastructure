#!/bin/bash
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
echo "Buckets to delete: $buckets"
for bucket in $buckets; do
  aws s3 rb s3://$bucket --force
done