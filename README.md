[![Publish Docker image](https://github.com/tle06/mgm-infra/actions/workflows/publish.yaml/badge.svg)](https://github.com/tle06/mgm-infra/actions/workflows/publish.yaml)
![Docker hub version](https://img.shields.io/docker/v/tlnk/mgm-infra?sort=date)
# Management infrastructure

## Description

This image is build to be use with gitlab CI/CD pipeline. The target is to deploy terraform and ansible configuration with gitlab CI/CD.

## Supported tags and respective

* latest [Dockerfile](https://github.com/tle06/docker-wikijs/blob/master/Dockerfile)
* [docker hub](https://hub.docker.com/r/tlnk/mgm-infra)

## Image configuration

Build from [python:latest](https://hub.docker.com/_/python)

Added packages:

* nano
* libssl-dev
* libffi-dev
* python-dev
* openssl
* unzip
* curl
* git
* iputils-ping
* make
* python-jmespath
* go
* ansible
* ansible-lint
* pywinrm
* netaddr
* pexpect
* passlib
* ansible[azure]
* kubernetes-validate
* openshift
* PyYAML
* ruamel.yaml
* PyMySQL
* yamlpath
* terraform
* [terraform-provider-hcloud](https://github.com/terraform-providers/terraform-provider-hcloud)
* [terraform-provider-ansible](https://github.com/nbering/terraform-provider-ansible/)
* [terraform Inventory](https://github.com/nbering/terraform-inventory)
* [aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* [Helm](https://helm.sh/docs/intro/install/)
* [knativectl](https://knative.dev/docs/install/install-kn/)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
* [Azure module](https://github.com/ansible-collections/azure)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Argoctl](https://github.com/argoproj/argo-cd/releases)
* [glooctl](https://github.com/solo-io/gloo/releases)
* [docopt](http://docopt.org/)

* workdir = /root

## How to use this image

### Start mgm-infra

Starting the wikijs instance listening on port 80 is as easy as the following:

``` Docker
docker run -d --restart=unless-stopped tlnk/mgm-infra:tag
```

## how to use this image with gitlab CI/CD

The exemple below show ansible integration with 2 step

1. lint of the file
2. ansible deployment with the load of the SSH key and dynamic inventory from terraform

```yml
stages:
  - job-ansible-lint
  - job-ansible-deploy

job-ansible-lint:
  stage: job-ansible-lint
  image: tlnk/mgm-infra:tag
  script:
    - cp -r /builds/gitlabusername/infrastructure/ansible /root/ansible
    - cd /root/ansible
    - ansible-lint *.yml -v
  only:
    refs:
      - master
    changes:
      - ansible/*

job-ansible-deploy:
  stage: job-ansible-deploy
  image: tlnk/mgm-infra:tag
  script:
    - eval $(ssh-agent -s)
    - touch /root/.ssh/id_rsa
    - echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
    - chmod 600 /root/.ssh/id_rsa
    - ansible-playbook -i /etc/ansible/terraform.py -u root ansible/infra.yml
  when: on_success
  only:
    refs:
      - master
    changes:
      - ansible/*
```
