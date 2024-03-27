from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.security import KMS
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack

with Diagram("\nTerraform CD pipeline Infra Design VilnaCRM", show=False, filename="../img/terraform_prod_env_cd_pipeline_infra_design"):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Artifact Bucket")
    codepipeCluster = Cluster("CodePipeline")
    kms = KMS("AWS KMS \n Encrypts all data")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    sns = SNS("AWS SNS \n Notify about \n pipeline progress")
    
    with codepipeCluster:
          builders = [ Codebuild("AWS CodeBuild \n terraspace validate"),
          Codebuild("AWS CodeBuild \n terraspace plan"),
          Codebuild("AWS CodeBuild \n terraspace up"),
          Codebuild("AWS CodeBuild \n deploy content"),
          Codebuild("AWS CodeBuild \n healthchecks") ]

    gh >> codepipe

    builders[0] >> builders[1] >> builders[2] >> builders[3] >> builders[4]

    codepipe >> builders[0]

    for builder in builders: 
        builder >> s3
    
    s3 >> Edge() << kms

    builders[4] >> sns

    sns >> chatbot

    chatbot >> Slack("Slack \n Notifications")