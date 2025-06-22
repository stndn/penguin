#/bin/bash

# References:
# For sshd_config to take effect: https://askubuntu.com/a/1534466/1139477 (Ubuntu 24.04)


# Configurations to be used in the script
CFG_MAIN_USER="example"             # Main user for additional set up (e.g. Docker)
CFG_TIMEZONE="Asia/Kuala_Lumpur"    # Timezone for the server
CFG_TIMESTAMP=$(date "+%Y%m%d")
CFG_LOG_TXT="\nCustomization::"

# Flags for optional installations, 1 for enable, 0 for disable
CFG_INSTALL_SSHD_CONFIG=1           # Override ssh config
CFG_INSTALL_DOCKER=1                # Install Docker and Compose


### Basic configuration

printf "${CFG_LOG_TXT} Set timezone to ${CFG_TIMEZONE}\n"
timedatectl set-timezone ${CFG_TIMEZONE}

printf "${CFG_LOG_TXT} Update OS packages and clean unused ones\n"
apt update && apt -y upgrade

printf "${CFG_LOG_TXT} Change default text editor to vim\n"
update-alternatives --set editor /usr/bin/vim.basic

printf "${CFG_LOG_TXT} Always ask for password on every sudo command\n"
sed -i -e 's/^\(Defaults\s\+\)env_reset$/\1env_reset,timestamp_timeout=0/' /etc/sudoers

printf "${CFG_LOG_TXT} Install extra packages\n"
apt install -y net-tools python3-pip ca-certificates curl

printf "${CFG_LOG_TXT} Clean up unused packages\n"
apt -y autoremove

printf "${CFG_LOG_TXT} Add timestamp to history for all users\n"
grep HISTTIMEFORMAT /etc/bash.bashrc | grep -v grep > /dev/null
HTF=$?
if [[ $HTF -eq 1 ]]; then
  cp -p /etc/bash.bashrc /etc/bash.bashrc.${CFG_TIMESTAMP}.bak
  echo "" >> /etc/bash.bashrc
  echo "# ${CFG_TIMESTAMP} - Add timestamp to history for all users" >> /etc/bash.bashrc
  echo "HISTTIMEFORMAT='%F %T '" >> /etc/bash.bashrc
  echo "" >> /etc/bash.bashrc
fi


### Optional installations

if [ "${CFG_INSTALL_SSHD_CONFIG}" -eq 1 ]; then
  # Override sshd_config
  printf "${CFG_LOG_TXT} Override sshd_config with custom file."
  printf "${CFG_LOG_TXT} Please check '../etc/ssh/sshd_config.d/18-custom.conf' and update the settings as necessary.\n"

  if [ -f /etc/ssh/sshd_config.d/18-custom.conf ]; then
    mv /etc/ssh/sshd_config.d/18-custom.conf /etc/ssh/sshd_config.d/18-custom.conf.${CFG_TIMESTAMP}.bak
  fi
  cp ../etc/ssh/sshd_config.d/18-custom.conf /etc/ssh/sshd_config.d
  chmod 600 /etc/ssh/sshd_config.d/18-custom.conf

  printf "${CFG_LOG_TXT} Socket configuration must be re-generated after changing Port, AddressFamily, or ListenAddress."
  printf "${CFG_LOG_TXT} For changes to take effect, run:\n\n"
  printf "   systemctl daemon-reload && systemctl restart ssh.socket\n"
  printf "   systemctl restart ssh\n"

  if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
    grep -E "^PasswordAuthentication yes$" /etc/ssh/sshd_config.d/50-cloud-init.conf > /dev/null
    RETCHECK=$?
    if [[ RETCHECK -eq 0 ]]; then
      printf "${CFG_LOG_TXT} Disable the 'PasswordAuthentication yes' setting that is present in '50-cloud-init.conf'\n"
      sed -i -E 's/^(PasswordAuthentication yes)$/# \1/' /etc/ssh/sshd_config.d/50-cloud-init.conf
    fi
  fi
fi


if [ "${CFG_INSTALL_DOCKER}" -eq 1 ]; then
  # Install Docker and Compose

  printf "${CFG_LOG_TXT} Remove unofficial Docker packages (if any)\n"
  apt remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

  printf "${CFG_LOG_TXT} Set up Docker 'apt' repository\n"

  # Add Docker's official GPG key:
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  printf \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && printf "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  printf "${CFG_LOG_TXT} Install Docker\n"

  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  printf "${CFG_LOG_TXT} Add main user ID '${CFG_MAIN_USER}' to the 'docker' group to run Docker commands without sudo\n"
  usermod -aG docker ${CFG_MAIN_USER}
fi

printf "\n\n------- Done: $(date) -------\n\n"
