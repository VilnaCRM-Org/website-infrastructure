from diagrams import Diagram, Edge
from diagrams.onprem.vcs import Github
from diagrams.aws.network import Route53, CF
from diagrams.aws.compute import Lambda
from diagrams.aws.management import Cloudwatch
from diagrams.aws.storage import S3
from diagrams.onprem.client import User, Users
from diagrams.custom import Custom

with Diagram("\nFrontend Infra Design VilnaCRM", show=False, filename="../img/frontend_infra_design"):

    uptimerobot = Custom("\n\n\nUptimeRobot", "../src/uptimerobot.png")
    route53 = Route53("AWS Route 53")
    cloudfront = CF("AWS Cloudfront")
    lamb = Lambda("AWS Lambda")
    cloudwatch = Cloudwatch("AWS CloudWatch")
    s3 = S3("AWS S3 \n Static Resources")

    Users("Customers") >> route53
    uptimerobot >> route53 >> cloudfront >> lamb >> cloudwatch
    lamb >> s3
    s3 >> cloudwatch

    User("Developer")>> Github("Github Actions") >> s3    

