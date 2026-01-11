FROM boltops/terraspace:2.2.3-debian

# Pin Terraform to 1.14.3 for Terraspace runs.
RUN tfenv install 1.14.3 \
  && tfenv use 1.14.3
