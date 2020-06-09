#Dockerfile mgm-infra
FROM python:3.8.2
LABEL maintainer="tlnk.fr"

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG ANSIBLE_VERSION=2.9.6
ARG TERRAFORM_VERSION=0.12.24
ARG GO_VERSION=1.13.5
ARG TERRAFORM_PROVIDER_ANSIBLE=1.0.3
ARG HELM_VERSION=3.2.1
ARG KNATIVE_VERSION=0.14.0

RUN apt update -y && \
  apt install -y nano openssl unzip iputils-ping make curl && \
  mkdir -p /root/.ssh

RUN pip3 install ansible==${ANSIBLE_VERSION} ansible-lint docker-py pywinrm jmespath netaddr pexpect passlib

RUN pip3 install ansible[azure]

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

RUN cd /tmp && \
  wget https://raw.githubusercontent.com/tle06/terraform-inventory/master/terraform.py && \
  mkdir -p /etc/ansible && \
  mv terraform.py /etc/ansible/terraform.py && \
  chmod +x /etc/ansible/terraform.py

RUN cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install

RUN cd /tmp && \
  wget "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
  tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  chmod 700 /usr/local/bin/helm

RUN cd /tmp && \
  wget "https://github.com/knative/client/releases/download/v${KNATIVE_VERSION}/kn-linux-amd64" && \
  mv kn-linux-amd64 /usr/local/bin/kn && \
  chmod 700 /usr/local/bin/kn

RUN cd /tmp && \
  curl -sL https://aka.ms/InstallAzureCLIDeb -o installAzureCli.sh && \
  chmod a+x installAzureCli.sh && \
  ./installAzureCli.sh

RUN ansible-galaxy collection install azure.azcollection --force

WORKDIR /root/
CMD ["bash"]

LABEL org.label-schema.version=$VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url="https://github.com/tle06/mgm-infra.git"
LABEL org.label-schema.name="mgm-infra"
LABEL org.label-schema.vendor="mgm-infra"
LABEL org.label-schema.schema-version="1.0"
