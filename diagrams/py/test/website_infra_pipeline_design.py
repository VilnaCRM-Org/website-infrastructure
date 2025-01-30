from diagrams import Cluster, Diagram
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack

with Diagram(
    "\nWebsite Infrastructure Terraform pipeline Test Design VilnaCRM",
    show=False,
    filename="../../img/test/website_infra_pipeline_design",
):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Artifact Bucket")
    website_infra_codepipeline = Cluster("Website Infra CodePipeline")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    sns = SNS("AWS SNS \n Notify about \n pipeline progress")

    with website_infra_codepipeline:
        builders = [
            Codebuild("AWS CodeBuild \n terraspace validate"),
            Codebuild("AWS CodeBuild \n terraspace plan"),
            Codebuild(
                "AWS CodeBuild \n terraspace up & trigger \n CI/CD Website CodePipeline"
            ),
        ]

    gh >> codepipe

    builders[0] >> builders[1] >> builders[2]

    codepipe >> builders[0]

    for builder in builders:
        builder >> s3

    builders[2] >> sns

    sns >> chatbot

    chatbot >> Slack("Slack \n Notifications")
