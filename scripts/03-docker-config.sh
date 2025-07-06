#!/bin/bash

# Extra user-specific configuration to be executed as regular user

CFG_TIMESTAMP=$(date "+%Y%m%d")
CFG_LOG_TXT="Customization::"

# Flags for optional configuration, 1 for enable, 0 for disable
CFG_CONFIGURE_DOCKER=1              # Configure Docker


### Optional configurations

if [[ "${CFG_CONFIGURE_DOCKER}" -eq 1 ]]; then
  printf "${CFG_LOG_TXT} Create Docker network\n"
  docker network create -d bridge --subnet 10.10.17.0/24 --gateway 10.10.17.1 dockernet
fi

