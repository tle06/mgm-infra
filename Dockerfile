#Dockerfile mgm-infra
FROM python:latest
LABEL maintainer="tlnk.fr"

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG TERRAFORM_VERSION




RUN apt update -y && \
  apt install -y nano openssl unzip iputils-ping && \
  mkdir -p /root/.ssh

RUN pip install ansible ansible-lint docker-py

RUN cd /tmp && \
  wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_linux_amd64.zip && \
  unzip terraform_0.12.16_linux_amd64.zip && \
  mv terraform /usr/local/bin/ && \
  rm terraform_0.12.16_linux_amd64.zip

WORKDIR /root/
CMD ["bash"]

LABEL org.label-schema.version=$VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url="https://github.com/tle06/mgm-infra.git"
LABEL org.label-schema.name="mgm-infra"
LABEL org.label-schema.vendor="mgm-infra"
LABEL org.label-schema.schema-version="1.0"
