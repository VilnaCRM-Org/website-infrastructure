from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack

with Diagram(
    "\nSandbox Infrastructure Terraform pipeline Prod Design VilnaCRM",
    show=False,
    filename="../../img/prod/sandbox_pipeline_design",
):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Sandbox Bucket")
    website_infra_codepipeline = Cluster("Sandbox CodePipeline")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    sns = SNS("AWS SNS \n Notify about \n pipeline progress")

    with website_infra_codepipeline:
        builders = [
            Codebuild("AWS CodeBuild \n up"),
            Codebuild("AWS CodeBuild \n deploy"),
        ]

    gh >> codepipe

    builders[0] >> builders[1]

    codepipe >> builders[0]

    for builder in builders:
        builder >> s3

    s3 >> Edge()

    builders[1] >> sns

    sns >> chatbot

    chatbot >> Slack("Slack \n Notifications")
