<!-- markdownlint-disable MD041 -->
[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://supportukrainenow.org/)

# VilnaCRM Infrastructure

![Latest Stable Version](https://poser.pugx.org/VilnaCRM-Org/infrastructure/v/stable.svg)
[![Test status](https://github.com/VilnaCRM-Org/infrastructure/workflows/Tests/badge.svg)](https://github.com/VilnaCRM-Org/infrastructure/actions)
[![codecov](https://codecov.io/gh/VilnaCRM-Org/infrastructure/branch/main/graph/badge.svg?token=J3SGCHIFD5)](https://codecov.io/gh/VilnaCRM-Org/infrastructure)

## Possibilities

- Modern stack for infrastructure: [Terraform](https://www.terraform.io/), [AWS](https://aws.amazon.com/)
- [Terraspace - terraform framework](https://terraspace.cloud/)
- Built-in docker environment and convenient `make` cli command
- A lot of CI checks to ensure the highest code quality that can be ([Infracost](https://www.infracost.io/), [Checkov](https://www.checkov.io/), Security checks, Code style fixer)
- Configured testing tool - [Terraform compliance](https://terraform-compliance.com/)
- A command line tool that runs HTTP requests defined in a simple plain text format - [Hurl](https://hurl.dev)
- Task runner / build tool - [Task](https://taskfile.dev)
- Much more!

## License

This software is distributed under the [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/deed) license. Please read [LICENSE](https://github.com/VilnaCRM-Org/infrastructure/blob/main/LICENSE) for information on the software availability and distribution.

## Infrastructure

Here you can get acquainted with our infrastructure for frontend and CD pipeline for terraform!

### Frontend Infrastructure

![Frontend Infrastructure](/diagrams/img/frontend_infra_design.png)

### Terraform Codepipeline Infrastructure

#### Production Environment

![CI/CD Infrastructure Terraform pipeline Production Design VilnaCRM](/diagrams/img/prod/ci_cd_infra_pipeline_design.png)

![Website Infrastructure Terraform pipeline Production Design VilnaCRM](/diagrams/img/prod/website_infra_pipeline_design.png)

![CI/CD Website pipeline Production Design VilnaCRM](/diagrams/img/prod/ci_cd_website_pipeline_design.png)

#### Test Environment

![CI/CD Infrastructure Terraform pipeline Test Design VilnaCRM](/diagrams/img/test/ci_cd_infra_pipeline_design.png)

![Website Infrastructure Terraform pipeline Test Design VilnaCRM](/diagrams/img/test/website_infra_pipeline_design.png)

![CI/CD Website pipeline Test Design VilnaCRM](/diagrams/img/test/ci_cd_website_pipeline_design.png)

Used AWS Services: Chatbot, Cloudwatch, S3, CodeBuild, CodePipeline, CodeStar, IAM, DNS, Cloudfront, SNS, Lambda.

## Installation

### AWS Credentials
---

For using this repository we recommend to use different AWS accounts. One for your production version, second for testing changes in infrastructure. Also it can be as many as you want. You will need just to create another tfvars variables file.

Let`s move tp the installation.

#### AWS Console
---
After creating your account you should do the following steps:

1. **Create CodeStar Connection:**

   Search -> Codepipeline -> Settings -> Connections -> Create connection -> Choose Github -> Enter Connection Name -> Install a new app -> Choose your account -> Authenticate -> Choose your app from Gihub Apps -> Connect.

   Recommended connection name: "**Github**", otherwise you will need change in `tfvars`.

2. **Connect your Slack workspace to AWS Chatbot:**

   Search -> AWS Chatbot -> Configure a chat client -> Chat Client(Slack) -> Configure Client.

   After, it will redirect you to your workspace where you will need to allow AWS Chatbot to use your workspace.

3. **Create IAM user for terraform:**

   Search -> IAM -> Users -> Create user -> Enter User Name -> Next -> Attach policies directly -> Check AdministratorAccess -> Create user

   After creation of user:

   Press on user you just created -> Go to Security credentials -> Create access key -> Choose  code -> Check Confirmation mark -> Next -> Enter description value -> Create access key -> Save the Access key and Secret access key credentials

**Save them, you will need it later.**

Also you will need your own domain.

#### AWS Domain
---
[Register or transfer](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html) your domain to the Route53.

You can read [this article](https://www.linkedin.com/pulse/how-migrate-external-domain-dns-service-aws-route-53-harry-singh/) if you have troubles with transferring domain.(Optional - [validate domain ownership](https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html))

#### Slack Notifications
---
If you don\`t need Slack Notification, just set `create_slack_notification` in `tvars/base.tfvars` to `false`. variable to false and skip this step.

**Otherwise,** you will need Workspace ID and Channel ID`s from your Slack.

Channels that you will need:
- Deployments Notification Channel.
- Reports Channel.
- CI/CD Alerts Channel.
- Website Alerts Channel.

To get them you need:

1. Launch your internet browser and log into your Slack account.

2. Once you're signed in, navigate to your primary workspace page and find the URL in the top search bar.

**The URL should follow this format: <https://app.slack.com/client/T111111L222/C3333333ZPF>**

The string of letters and numbers beginning with **"T"** is your workspace ID.

The string of letters and numbers beginning with **"C"** is your channel ID.(Also you can get it in the channel details).

**Save them for later.**

### Local machine software requirements

Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [Ruby](https://terraspace.cloud/docs/install/ruby/), [Docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/install/) on your machine.
You need to use the latest [Ubuntu](https://ubuntu.com/) and set up the project locally using this OS. Follow the guides specified in the links.

Necessary Terraform Version for the Terraspace is 1.14.3. Upgrade from 1.4.7 by
backing up state, running `terraform init --reconfigure`, and validating in a
non-production environment because state/backend upgrades are irreversible. Review
breaking changes from 1.4.7 through 1.14.3 (including intermediate versions) before upgrading. See the [Terraform 1.14
upgrade notes](https://developer.hashicorp.com/terraform/language/upgrade-guides/1-14)
for details on breaking changes. Please, follow this links to install  [Terraform](https://terraspace.cloud/docs/install/terraform/) and [Terraspace](https://terraspace.cloud/docs/install/gem/) to install it.

Or you can use `make install-terraspace`.

Also you need to set up the connection to your AWS Account. With the credentials you got before use `aws configure`.

```bash
$aws configure
AWS Access Key ID [None]: <Your Access Key Here>
AWS Secret Access Key [None]: <Your Secret Key Here>
Default region name [None]: eu-central-1
Default output format [None]:
```

In case you are using any other region, please respecify it in the `tfvars`. Also specify your own domain name in the `tfvars`.

After you can move to the next step.

### Environmental variables

Also before running you need to set up some local variables:
- **TF_VAR_SLACK_WORKSPACE_ID** - ID of your Slack workspace.
- **TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID** - ID of Slack channel where the deployments notification will be posted.
- **TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID** - ID of Slack channel where the CodePipeline alerts will be posted.
- **TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID** - ID of Slack channel where the Website alerts will be posted.
- **TF_VAR_REPORT_SLACK_CHANNEL_ID** - ID of Slack channel where the reports of the website tests will be posted.
- **GITHUB_OWNER** - Owner of the repositories. Default: `VilnaCRM-Org`.
- [**GITHUB_TOKEN**](/.github/github-token-usage.md) - Token that will be used both to configure the GitHub Provider in Terraform and in CodePipelines for creating, recreating infrastructure, and other tasks.

Note: if you are not using Slack Notifications, skip those variables.

### Bringing up the infrastucture

After you configured everything you can deploy infrastructure by running such commands in order.
- `make terraspace-all-init`
- `make terraspace-all-validate`
- `make terraspace-all-up`

After you deployed you can create the website infrastructure itself using.
- `terraspace all up`

Alternatively, you can use the following command to bring up the entire infrastructure stack:

- `make terraspace-up stack=ci-cd-infrastructure`

This command simplifies the process by targeting the ci-cd-infrastructure stack directly.

**⚠️ Important Note:**  
The deployed sandbox will be automatically **removed after 7 days**.
To keep it active, the developer must **commit again** to redeploy it.

### Instructions on how to set up and run the changes in AWS

CLI Instructions:
Once you have made the changes, you can run the pipeline using the `make` capabilities. If you already have the infrastructure, don't forget to apply the changes before running the pipeline.

> make trigger-pipeline

Run the command for each pipeline specifying its name, see the list of `make` possibilities for details on how to properly run this trigger


AWS Management Console Instructions:
Before running, make sure you have applied the changes made earlier.

Search -> Codepipeline -> Pipelines -> Select a pipeline using the checkbox on the left -> Release change -> Release

Follow these steps for each pipeline.

## Using make

You can use `make` command to easily control and work with project locally.

> make install

This command installs all that you need to start working with Terraspace framework.

Execute `make` or `make help` to see the full list of project commands.

The list of the `make` possibilities:

```bash

  codebuild-local-set-up         Setting up CodeBuild Agent for testing buildspecs locally
  codebuild-run                  Running CodeBuild for specific buildspec. Example: make codebuild-run buildspec='aws/buildspecs/website/buildspec_deploy.yml'
  tf-fmt                         Format terraform code recursively.
  terraspace-all-init            Init all the stacks. 
  terraspace-all-validate        Validate all the stacks. 
  terraspace-all-plan-file       Plan all the stacks into file. Variables: env, out.
  terraspace-all-plan            Plan all the stacks. Variables: env.
  terraspace-all-up-plan         Up all the stacks from the plan. Variables: env, plan.
  terraspace-all-up              Up all the stacks. Variables: env.
  terraspace-all-output-file     Output all the stacks variables into file. Variables: env, out.
  terraspace-all-output          Output all the stacks variables. Variables: env.
  terraspace-all-down            Down all the stacks.
  terraspace-init                Init the stack. Variables: env, stack.
  terraspace-validate            Validate the stack. Variables: env, stack.
  terraspace-plan-file           Plan the stack into file. Variables: env, stack, out.
  terraspace-plan                Plan the stack. Variables: env, stack.
  terraspace-up-plan             Up the stack from plan. Variables: env, stack, plan.
  terraspace-up                  Up the stack. Variables: env, stack.
  terraspace-output-file         Output the stack variables into file. Variables: env, stack, out.
  terraspace-output              Output the stack variables. Variables: env, stack.
  terraspace-down                Down the stack. Variables: env, stack.
  trigger-pipeline:              Trigger AWS CodePipeline. Variables: pipeline. Example: make trigger-pipeline pipeline=ci-cd-infra-test-pipeline

```

## Documentation

Start reading at the [GitHub wiki](https://github.com/VilnaCRM-Org/website-infrastructure/wiki). If you're having trouble, head for [the troubleshooting guide](https://github.com/VilnaCRM-Org/website-infrastructure/wiki/Troubleshooting) as it's frequently updated.

If the documentation doesn't cover what you need, search the [many questions on Stack Overflow](http://stackoverflow.com/questions/tagged/vilnacrm), and before you ask a question, [read the troubleshooting guide](https://github.com/VilnaCRM-Org/website-infrastructure/wiki/Troubleshooting).

## Security

Please disclose any vulnerabilities found responsibly – report security issues to the maintainers privately.

See [SECURITY](https://github.com/VilnaCRM-Org/infrastructure/tree/main/SECURITY.md) and [Security advisories on GitHub](https://github.com/VilnaCRM-Org/infrastructure/security).

## Contributing

Please submit bug reports, suggestions, and pull requests to the [GitHub issue tracker](https://github.com/VilnaCRM-Org/infrastructure/issues).

We're particularly interested in fixing edge cases, expanding test coverage, and updating translations.

If you found a mistake in the docs, or want to add something, go ahead and amend the wiki – anyone can edit it.

## Sponsorship

Development time and resources for this repository are provided by [VilnaCRM](https://vilnacrm.com/), the free and opensource CRM system.

Donations are very welcome, whether in beer 🍺, T-shirts 👕, or cold, hard cash 💰. Sponsorship through GitHub is a simple and convenient way to say "thank you" to maintainers and contributors – just click the "Sponsor" button [on the project page](https://github.com/VilnaCRM-Org/infrastructure). If your company uses this template, consider taking part in the VilnaCRM's enterprise support program.

## Changelog

See [changelog](CHANGELOG.md).


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
