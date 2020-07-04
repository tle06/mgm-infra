#Dockerfile mgm-infra
# ---------------------------------------------------------------------------- #
#                                Download files                                #
# ---------------------------------------------------------------------------- #

FROM busybox:1.31.1 AS download

ARG TERRAFORM_VERSION=0.12.24
ARG TERRAFORM_PROVIDER_ANSIBLE=1.0.3
ARG HELM_VERSION=3.2.1
ARG KNATIVE_VERSION=0.14.0

WORKDIR /tmp

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN wget https://github.com/nbering/terraform-provider-ansible/releases/download/v${TERRAFORM_PROVIDER_ANSIBLE}/terraform-provider-ansible-linux_amd64.zip && \
  unzip terraform-provider-ansible-linux_amd64.zip && \
  mv linux_amd64/terraform-provider-ansible_v${TERRAFORM_PROVIDER_ANSIBLE} linux_amd64/terraform-provider-ansible && \
  rm terraform-provider-ansible-linux_amd64.zip

RUN wget "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
  tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

RUN wget "https://github.com/knative/client/releases/download/v${KNATIVE_VERSION}/kn-linux-amd64"

RUN wget https://raw.githubusercontent.com/tle06/terraform-inventory/master/terraform.py && \
  wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
  unzip awscliv2.zip && \
  rm awscliv2.zip

# ---------------------------------------------------------------------------- #
#                                  Final image                                 #
# ---------------------------------------------------------------------------- #

FROM python:3.8.2-slim-buster
LABEL maintainer="tle@tlnk.fr"

ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG ANSIBLE_VERSION=2.9.6

RUN apt update -y && \
  apt install -y nano openssl unzip iputils-ping libssl-dev libffi-dev python-dev curl git && \
  mkdir -p /tmp && \
  mkdir -p /root/.ssh && \
  mkdir -p /root/.terraform.d/plugins/linux_amd64 && \
  mkdir -p /etc/ansible

COPY --from=download /tmp/terraform /usr/local/bin/terraform
COPY --from=download /tmp/linux_amd64/terraform-provider-ansible /root/.terraform.d/plugins/linux_amd64/terraform-provider-ansible
COPY --from=download /tmp/terraform.py /etc/ansible/terraform.py
COPY --from=download /tmp/aws /tmp/aws
COPY --from=download /tmp/linux-amd64/helm /usr/local/bin/helm
COPY --from=download /tmp/kn-linux-amd64 /usr/local/bin/kn
COPY cli/installAzureCli.sh /tmp/installAzureCli.sh

RUN pip3 install ansible==${ANSIBLE_VERSION}

RUN pip3 install ansible-lint docker-py pywinrm jmespath netaddr pexpect passlib kubernetes-validate openshift PyYAML && \
  pip3 install ansible[azure] && \
  ansible-galaxy collection install azure.azcollection --force && \
  ./tmp/aws/install && \
  chmod a+x /tmp/installAzureCli.sh && \
  ./tmp/installAzureCli.sh

RUN chmod +x /etc/ansible/terraform.py && \
  chmod 700 /usr/local/bin/kn && \
  chmod 700 /usr/local/bin/helm && \
  rm -rf /tmp/* && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /root/
CMD ["bash"]

LABEL org.label-schema.name="mgm-infra"
LABEL org.label-schema.description="Tool to deploy infrastructure as code"
LABEL org.label-schema.url="https://github.com/tle06/mgm-infra"
LABEL org.label-schema.vendor="TLNK"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url="https://github.com/tle06/mgm-infra.git"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.docker.cmd="docker run -t -i tlnk/mgm-infra"