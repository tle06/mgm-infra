# Management infrastructure

## Description

This image is build to be use with gitlab CI/CD pipeline. The target is to deploy terraform and ansible configuration with gitlab CI/CD.

## Supported tags and respective

* latest [Dockerfile](https://github.com/tle06/docker-wikijs/blob/master/Dockerfile)

## Image configuration

Build from [python:latest](https://hub.docker.com/_/python)

Added packages:

* nano
* openssl
* unzip
* iputils-ping
* make
* go
* ansible
* ansible-lint
* terraform
* terraform-provider-hcloud

* workdir = /root

## How to use this image

### Start mgm-infra

Starting the wikijs instance listening on port 80 is as easy as the following:

``` Docker
docker run -d --restart=unless-stopped tlnk/mgm-infra
```

### Use docker compose

``` Docker
version: '2'
services:
  wiki:
    image: tlnk/mgm-infra
```

## how to use this image with gitlab CI/CD

The exemple below show ansible integration with 2 step

1. lint of the file
2. ansible deployment with the load of the SSH key

```yml
stages:
  - job-ansible-lint
  - job-ansible-deploy

job-ansible-deploy:
  stage: job-ansible-deploy
  image: tlnk/mgm-infra
  script:
    - eval $(ssh-agent -s)
    - touch /root/.ssh/id_rsa
    - echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
    - chmod 600 /root/.ssh/id_rsa
    - ansible-playbook -i ansible/inventory -u root ansible/infra.yml
  when: on_success
  only:
    refs:
      - master
    changes:
      - ansible/*

job-ansible-lint:
  stage: job-ansible-lint
  image: tlnk/mgm-infra
  script:
    - cp -r /builds/tle06/infrastructure/ansible /root/ansible
    - cd /root/ansible
    - ansible-lint *.yml -v
  only:
    refs:
      - master
    changes:
      - ansible/*
```
