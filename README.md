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

![Production Terraform CD Pipeline Infrastructure](/diagrams/img/terraform_prod_env_cd_pipeline_infra_design.png)

#### Test Environment

![Test Terraform CD Pipeline Infrastructure](/diagrams/img/terraform_test_env_cd_pipeline_infra_design.png)

Used AWS Services: Chatbot, Cloudwatch, S3, CodeBuild, CodePipeline, CodeStar, KMS, IAM, DNS, Cloudfront, SNS, Lambda.

## Installation

### AWS Credentials

For using this repository we recommend to use different AWS accounts. One for your production version, second for testing changes in infrastructure. Also it can be as many as you want. You will need just to create another tfvars variables file.

#### AWS Console

After creating your account you should do the following steps:

1. **Create CodeStar Connection:**

   Search -> Codepipeline -> Settings -> Connections -> Create connection -> Choose Github -> Enter Connection Name -> Install a new app -> Choose your account -> Authenticate -> Choose your app from Gihub Apps -> Connect.

   Recommended connection name: "**Github**", otherwise you will need change in tfvars.

2. **Connect your Slack workspace to AWS Chatbot:**

   Search -> AWS Chatbot -> Configure a chat client -> Chat Client(Slack) -> Configure Client.

   After, it will redirect you to your workspace where you will need to allow AWS Chatbot to use your workspace.

3. **Create IAM user for terraform:**

   Search -> IAM -> Users -> Create user -> Enter User Name -> Next -> Attach policies directly -> Check AdministratorAccess -> Create user

   After creation of user:

   Press on user you just created -> Go to Security credentials -> Create access key -> Choose Local code -> Check Confirmation mark -> Next -> Enter description value -> Create access key -> Save the Access key and Secret access key credentials

**Save them, you will need it later.**

Also you will need your own domain.

#### AWS Domain

[Register or transfer](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html) your domain to the Route53.

You can read [this article](https://www.linkedin.com/pulse/how-migrate-external-domain-dns-service-aws-route-53-harry-singh/) if you have troubles with transferring domain.(Optional - [validate domain ownership](https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html))

#### Slack Notifications

If you don\`t need Slack Notification, just set `create_slack_notification` variable to false and skip this step.

**Otherwise,** you will need Workspace ID and Channel ID`s from your Slack.

To get them you need:

1. Launch your internet browser and log into your Slack account.

2. Once you're signed in, navigate to your primary workspace page and find the URL in the top search bar.

**The URL should follow this format: https://app.slack.com/client/T111111L222/C3333333ZPF**

The string of letters and numbers beginning with **"T"** is your workspace ID.

The string of letters and numbers beginning with **"C"** is your channel ID.(Also you can get it in the channel details).

**Save them for later.**

### Local machine

Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli), [Ruby](https://terraspace.cloud/docs/install/ruby/), [Terraspace](https://terraspace.cloud/docs/install/gem/), [Docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/install/) on your machine. Follow the guides specified in the links.

After installing software you can move to next steps.

## Using make

Use `make` command to set up project and automatically install all needed dependencies

> make start

This command allows to easily control and work with project locally.

Execute `make` or `make help` to see the full list of project commands.

The list of the `make` possibilities:

## Documentation

Start reading at the [GitHub wiki](https://github.com/VilnaCRM-Org/infrastructure/wiki). If you're having trouble, head for [the troubleshooting guide](https://github.com/VilnaCRM-Org/infrastructure/wiki/Troubleshooting) as it's frequently updated.

If the documentation doesn't cover what you need, search the [many questions on Stack Overflow](http://stackoverflow.com/questions/tagged/vilnacrm), and before you ask a question, [read the troubleshooting guide](https://github.com/VilnaCRM-Org/infrastructure/wiki/Troubleshooting).

## Tests

[Tests](https://github.com/VilnaCRM-Org/infrastructure/tree/main/tests/) use [Terraform Compliance](https://terraform-compliance.com/).

[![Test status](https://github.com/VilnaCRM-Org/infrastructure/workflows/Tests/badge.svg)](https://github.com/VilnaCRM-Org/infrastructure/actions)

If this isn't passing, is there something you can do to help?

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
