from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.security import KMS
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack

with Diagram("\nCI/CD Infrastructure Terraform pipeline Test Design VilnaCRM", show=False, filename="../../img/test/ci_cd_infra_pipeline_design"):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Artifact Bucket")
    ci_cd_infra_codepipeline = Cluster("CI/CD Infra CodePipeline")
    kms = KMS("AWS KMS \n Encrypts all data")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    sns = SNS("AWS SNS \n Notify about \n pipeline progress")

    with ci_cd_infra_codepipeline:
        builders = [Codebuild("AWS CodeBuild \n terraspace validate"),
                    Codebuild("AWS CodeBuild \n terraspace plan"),
                    Codebuild("AWS CodeBuild \n terraspace up"),]

    gh >> codepipe

    builders[0] >> builders[1] >> builders[2]

    codepipe >> builders[0]

    for builder in builders:
        builder >> s3

    s3 >> Edge() << kms

    builders[2] >> sns

    sns >> chatbot

    chatbot >> Slack("Slack \n Notifications")
