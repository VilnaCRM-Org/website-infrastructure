project_name               = "website-test"
website_infra_project_name       = "website-infra-test"
ci_cd_infra_project_name         = "ci-cd-infra-test"
environment                = "test"
github_connection_name     = "Github"
secretsmanager_secret_name = "test/AWS/Website"
website_url                = "vilnacrmtest.com"
bucket_name                = "vilnacrmtest.com"

tags = {
  Project     = "website-test"
  Environment = "test"
}

