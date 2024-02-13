touch config
touch credentials
echo "[profile terraform]" >config
echo "region = ${AWS_DEFAULT_REGION}" >>config
echo "[terraform]" >credentials
echo "aws_access_key_id = $(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text | jq -r ".WEBSITE_AWS_ACCESS_KEY")" >>credentials
echo "aws_secret_access_key = $(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text | jq -r ".WEBSITE_AWS_SECRET_KEY")" >>credentials
mkdir ~/.aws/
mv config ~/.aws/config
mv credentials ~/.aws/credentials
export AWS_PROFILE=terraform
