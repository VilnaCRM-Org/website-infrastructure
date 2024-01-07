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
- Much more!

## License
This software is distributed under the [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/deed) license. Please read [LICENSE](https://github.com/VilnaCRM-Org/infrastructure/blob/main/LICENSE) for information on the software availability and distribution.

### Minimal installation
You can clone this repository locally

Register or transfer your domain to the Route53 - [link](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar.html)

You can read [this article](https://www.linkedin.com/pulse/how-migrate-external-domain-dns-service-aws-route-53-harry-singh/) if you have troubles with transferring domain

Optional - [validate domain ownership](https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html)

Install the latest [docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/install/)

Use `make` command to set up project and automatically install all needed dependencies
> make start

That's it. You should now be ready to develop infrastructure!

## Using
You can use `make` command to easily control and work with project locally.

Execute `make` or `make help` to see the full list of project commands.

The list of the `make` possibilities:

```

```

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
