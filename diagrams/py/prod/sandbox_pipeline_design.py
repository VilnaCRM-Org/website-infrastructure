from diagrams import Cluster, Diagram
from diagrams.onprem.vcs import Github
from diagrams.aws.devtools import Codepipeline, Codebuild
from diagrams.aws.storage import SimpleStorageServiceS3

with Diagram(
    "\nSandbox Infrastructure Terraform pipeline Prod Design VilnaCRM",
    show=False,
    filename="../../img/prod/sandbox_pipeline_design",
):
    gh = Github("Github Repository")
    codepipe = Codepipeline("AWS CodePipeline")
    s3 = SimpleStorageServiceS3("AWS S3 \n Sandbox Bucket")
    website_infra_codepipeline = Cluster("Sandbox CodePipeline")

    with website_infra_codepipeline:
        builders = [
            Codebuild("AWS CodeBuild \n up"),
            Codebuild("AWS CodeBuild \n deploy"),
            Codebuild("AWS CodeBuild \n healthcheck"),
        ]

    gh >> codepipe

    builders[0] >> builders[1] >> builders[2]

    codepipe >> builders[0]

    builders[0] >> s3
    builders[1] >> s3

    gh_pr_comments = Github("Github \n PR Comments")

    builders[1] >> gh_pr_comments
    builders[2] >> gh_pr_comments
