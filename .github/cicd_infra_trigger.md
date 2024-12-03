# Documentation for Workflow: Trigger AWS CI-CD-Infra CodePipeline

This documentation provides an overview of the GitHub Actions workflow used to trigger the AWS CodePipeline for CI/CD infrastructure. It includes setup instructions for required secrets and environment variables.
Workflow Overview

Filename: .github/workflows/trigger-aws-ci-cd-infra-codepipeline.yml

Purpose:
This workflow triggers the AWS CodePipeline responsible for CI/CD infrastructure updates whenever a push occurs to any branch except the main branch.

Key Features:

   Skips execution for pushes to the main branch.
   Uses OpenID Connect (OIDC) for secure authentication with AWS.
   Requires minimal configuration and uses reusable secrets.

Required Secrets

   AWS_CI_CD_INFRA_ROLE_TO_ASSUME
   Description: The Amazon Resource Name (ARN) of the AWS IAM role that GitHub Actions will assume to interact with AWS services.

## Secrets Setup

   Add AWS_CI_CD_INFRA_ROLE_TO_ASSUME

   Description:
   This secret stores the ARN of the IAM role that GitHub Actions will assume via OIDC.

   Steps:
       Navigate to your GitHub repository: Settings > Secrets and variables > Actions > Secrets.
       Click New repository secret.
       Set the Name to AWS_CI_CD_INFRA_ROLE_TO_ASSUME.
       Set the Value to the ARN of your IAM role (e.g., arn:aws:iam::123456789012:role/CICDInfraRole).
       Click Add secret.

## Environment Variable

   AWS_REGION

   Description:
   This variable defines the AWS region where the CodePipeline is deployed.

   Steps:
       Navigate to your GitHub repository: Settings > Secrets and variables > Actions > Variables.
       Click New repository variable.
       Set the Name to AWS_REGION.
       Set the Value to your desired AWS region (e.g., us-east-1).
       Click Add variable.

## IAM Role Configuration

To use this workflow, ensure that the AWS IAM role specified in AWS_CI_CD_INFRA_ROLE_TO_ASSUME is properly configured for GitHub OIDC and has the necessary permissions to start the specified CodePipeline.
Trust Policy

Update the IAM role's trust relationship with the following policy, replacing placeholders with your information:

     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
             "StringLike": {
               "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/YOUR_REPO:*"
             },
             "StringEquals": {
               "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
             }
           }
         }
       ]
     }

Replace:

   YOUR_AWS_ACCOUNT_ID with your AWS account number.
   YOUR_GITHUB_ORG with your GitHub organization or username.
   YOUR_REPO with the repository name.

## Permission Policy

Attach the following permissions to the IAM role:

     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": "codepipeline:StartPipelineExecution",
           "Resource": "arn:aws:codepipeline:YOUR_REGION:YOUR_ACCOUNT_ID:ci-cd-infra-test-pipeline"
         }
       ]
     }

Replace:

   YOUR_REGION with your AWS region (e.g., us-east-1).
   YOUR_ACCOUNT_ID with your AWS account number.

Workflow Execution

   Push changes to any branch except main.
   Monitor GitHub Actions logs for workflow execution details.
   Verify pipeline execution in AWS CodePipeline.

## Additional Notes

   OIDC Authentication:
   By using OIDC, you enhance security by avoiding long-lived AWS credentials. Ensure the trust policy is correctly configured.

   Logging and Monitoring:
   Check the logs in GitHub Actions and AWS CodePipeline for errors or pipeline execution status.

   Workflow Placement:
   Place this workflow file in the .github/workflows/ directory of your repository.