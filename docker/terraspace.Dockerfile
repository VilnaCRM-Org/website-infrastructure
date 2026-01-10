FROM boltops/terraspace:2.2.3-debian

RUN tfenv install 1.10.5 \
  && tfenv use 1.10.5
