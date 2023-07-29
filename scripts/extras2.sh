#!/bin/bash

# Extras to be executed as regular user
# This should be after the root extras

# Download docker-compose
# Adjust the version from 2.3.3 to latest version available in https://github.com/docker/compose/releases
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify docker compose version
docker compose version

# Create docker network
docker network create -d bridge --subnet 10.10.17.0/24 --gateway 10.10.17.1 dockernet

# The rest are to install the relevant docker containers ...
