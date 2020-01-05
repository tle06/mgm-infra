#Dockerfile mgm-infra
FROM python:latest
LABEL maintainer="tlnk.fr"

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG TERRAFORM_VERSION=0.12.16
ARG GO_VERSION=1.13.5
ARG TERRAFORM_PROVIDER_ANSIBLE=1.0.3

RUN apt update -y && \
  apt install -y nano openssl unzip iputils-ping make && \
  mkdir -p /root/.ssh

RUN pip install ansible ansible-lint docker-py

RUN cd /tmp && \
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  mv terraform /usr/local/bin/ && \
  rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN cd /tmp && \
  wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
  rm go${GO_VERSION}.linux-amd64.tar.gz

RUN mkdir -p /root/go/src/github.com/terraform-providers/terraform-provider-hcloud && \
  cd /root/go/src/github.com/terraform-providers && \
  git clone https://github.com/terraform-providers/terraform-provider-hcloud.git && \
  cd /root/go/src/github.com/terraform-providers/terraform-provider-hcloud && \
  export PATH=$PATH:/usr/local/go/bin && \
  export GOPATH=$HOME/go && \
  export PATH=$PATH:$GOPATH/bin && \
  make build && \
  mkdir -p ~/.terraform.d/plugins && \
  cp /root/go/bin/terraform-provider-hcloud /root/.terraform.d/plugins/terraform-provider-hcloud

RUN cd /tmp && \
  wget https://github.com/nbering/terraform-provider-ansible/releases/download/v${TERRAFORM_PROVIDER_ANSIBLE}/terraform-provider-ansible-linux_amd64.zip && \
  unzip terraform-provider-ansible-linux_amd64.zip && \
  cp /tmp/linux_amd64/terraform-provider-ansible_v${TERRAFORM_PROVIDER_ANSIBLE} /root/.terraform.d/plugins/terraform-provider-ansible_v${TERRAFORM_PROVIDER_ANSIBLE} && \
  rm /tmp/terraform-provider-ansible-linux_amd64.zip && \
  rm -rf /tmp/linux_amd64

RUN wget -P /etc/ansible/ https://raw.githubusercontent.com/nbering/terraform-inventory/master/terraform.py && \
  chmod +x /etc/ansible/terraform.py

WORKDIR /root/
CMD ["bash"]

LABEL org.label-schema.version=$VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url="https://github.com/tle06/mgm-infra.git"
LABEL org.label-schema.name="mgm-infra"
LABEL org.label-schema.vendor="mgm-infra"
LABEL org.label-schema.schema-version="1.0"
