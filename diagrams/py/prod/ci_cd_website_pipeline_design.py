from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.security import KMS
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack
from diagrams.aws.network import CF

with Diagram("\nCI/CD Website pipeline Production Design VilnaCRM", show=False, filename="../../img/prod/ci_cd_website_pipeline_design"):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Artifact Bucket")
    ci_cd_website_codepipeline = Cluster("CI/CD Website CodePipeline")
    kms = KMS("AWS KMS \n Encrypts all data")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    sns = SNS("AWS SNS \n Notify about \n pipeline progress")

    with ci_cd_website_codepipeline:
        builders = [Codebuild("AWS CodeBuild \n batch-unit-mutation-lint"),
                    Codebuild("AWS CodeBuild \n deploy"),
                    Codebuild("AWS CodeBuild \n healthcheck"),
                    Codebuild("AWS CodeBuild \n batch-lhci-leak"),
                    Codebuild("AWS CodeBuild \n batch-pw-load"),
                    Codebuild("AWS CodeBuild \n release"),
                    ]

    gh >> codepipe

    builders[0] >> builders[1] >> builders[2] >> builders[3] >> builders[4] >> builders[5]

    builders[1] >> SimpleStorageServiceS3(
        "AWS S3 \n Website Static Files Staging Bucket")

    builders[5] >> CF("AWS Cloudfront \nDistributions Update")

    codepipe >> builders[0]

    for builder in builders:
        builder >> s3

    s3 >> Edge() << kms

    builders[5] >> sns

    sns >> chatbot

    chatbot >> Slack("Slack \n Notifications")
