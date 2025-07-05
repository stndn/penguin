#/bin/bash

# Install Docker on Debian 12.11

# References:
# https://docs.docker.com/engine/install/debian/


# Configurations to be used in the script
CFG_MAIN_USER="example"             # Main user for additional set up (e.g. Docker)
CFG_LOG_TXT="\nCustomization::"

printf "${CFG_LOG_TXT} Remove unofficial Docker packages (if any)\n"
apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc

printf "${CFG_LOG_TXT} Set up Docker 'apt' repository\n"

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
printf \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

printf "${CFG_LOG_TXT} Add main user ID '${CFG_MAIN_USER}' to the 'docker' group to run Docker commands without sudo\n"
usermod -aG docker ${CFG_MAIN_USER}

printf "\n\n------- Done: $(date) -------\n\n"
