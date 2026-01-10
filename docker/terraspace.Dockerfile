FROM boltops/terraspace:2.2.3-debian

# Terraspace 2.2.3 supports Terraform up to ~1.5.x; align the Terraform version accordingly.
RUN tfenv install 1.5.5 \
  && tfenv use 1.5.5
