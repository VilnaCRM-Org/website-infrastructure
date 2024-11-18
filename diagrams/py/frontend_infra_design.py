from diagrams import Diagram
from diagrams.onprem.vcs import Github
from diagrams.aws.network import Route53, CF
from diagrams.aws.compute import Lambda
from diagrams.aws.management import Cloudwatch
from diagrams.aws.storage import S3
from diagrams.onprem.client import User, Users
from diagrams.aws.management import Chatbot
from diagrams.aws.integration import SNS
from diagrams.saas.chat import Slack
from diagrams.custom import Custom

with Diagram(
    "\nFrontend Infra Design VilnaCRM",
    show=False,
    filename="../img/frontend_infra_design"
):

    uptimerobot = Custom("\n\n\nUptimeRobot", "../src/uptimerobot.png")
    route53 = Route53("AWS Route 53")
    cloudfront = CF("AWS Cloudfront")
    lamb = Lambda("AWS Lambda")
    lambNotifications = Lambda(
        "AWS Lambda\n Notify object stage \n using S3 Bucket Notifies"
    )
    cloudwatch = Cloudwatch("AWS CloudWatch")
    s3 = S3("AWS S3 \n Static Resources")
    snsCloudwatch = SNS("AWS SNS \n Cloudwatch Alarms")
    snsS3 = SNS("AWS SNS \n S3 object state")
    chatbot = Chatbot("AWS chatbot \n Send notifies \n to Slack")
    slack = Slack("Slack \n Notifications")

    Users("Customers") >> route53
    uptimerobot >> route53 >> cloudfront >> lamb >> cloudwatch >> snsCloudwatch >> chatbot >> slack
    lamb >> s3 >> cloudwatch

    s3 >> lambNotifications >> snsS3 >> chatbot >> slack

    User("Developer") >> Github("Github Actions") >> s3