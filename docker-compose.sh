#!/bin/bash

# Install Docker Compose
# https://docs.docker.com/compose/install/#install-compose

COMPOSE_VERSION=1.22.0

curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

/usr/local/bin/docker-compose --version
