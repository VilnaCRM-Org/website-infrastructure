touch config
touch credentials
aws_iam_output=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME)
access_key_id=$(echo $aws_iam_output | jq -r '.["Credentials"] | .["AccessKeyId"]')
secret_access_key=$(echo $aws_iam_output | jq -r '.["Credentials"] | .["SecretAccessKey"]')
session_token=$(echo $aws_iam_output | jq -r '.["Credentials"] | .["SessionToken"]')
echo "[profile terraform]" >config
echo "region = ${AWS_DEFAULT_REGION}" >>config
echo "[terraform]" >credentials
echo "aws_access_key_id = $access_key_id" >>credentials
echo "aws_secret_access_key = $secret_access_key" >>credentials
echo "aws_session_token = $session_token" >>credentials
mkdir ~/.aws/
mv config ~/.aws/config
mv credentials ~/.aws/credentials
export AWS_PROFILE=terraform
