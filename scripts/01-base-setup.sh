#/bin/bash

# References:
# Ubuntu 24.04 only: For sshd_config to take effect: https://askubuntu.com/a/1534466/1139477


# Configurations to be used in the script
CFG_TIMEZONE="Asia/Kuala_Lumpur"    # Timezone for the server
CFG_TIMESTAMP=$(date "+%Y%m%d")
CFG_LOG_TXT="\nCustomization::"

# Flags for optional installations, 1 for enable, 0 for disable
CFG_INSTALL_SSHD_CONFIG=1           # Override ssh config


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
apt install -y net-tools python3-pip ca-certificates curl tree htop

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

  # Print extra configuration requirement for Ubuntu
  if [ -f /etc/os-release ]; then
    OS_ID=$(cat /etc/os-release | grep '^ID=' | awk -F'=' '{print $2}')
    if [ "${OS_ID}" == "ubuntu" ]; then
      printf "${CFG_LOG_TXT} Ubuntu 24.04: Socket configuration must be re-generated after changing Port, AddressFamily, or ListenAddress."
      printf "${CFG_LOG_TXT} For changes to take effect, run:\n\n"
      printf "   systemctl daemon-reload && systemctl restart ssh.socket\n"
    fi

    printf "${CFG_LOG_TXT} Restart ssh service for the sshd configuration changes to take effect:\n\n"
    printf "   systemctl restart ssh\n"
  fi

  if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
    grep -E "^PasswordAuthentication yes$" /etc/ssh/sshd_config.d/50-cloud-init.conf > /dev/null
    RETCHECK=$?
    if [[ RETCHECK -eq 0 ]]; then
      printf "${CFG_LOG_TXT} Disable the 'PasswordAuthentication yes' setting that is present in '50-cloud-init.conf'\n"
      sed -i -E 's/^(PasswordAuthentication yes)$/# \1/' /etc/ssh/sshd_config.d/50-cloud-init.conf
    fi
  fi
fi


printf "\n\n------- Done: $(date) -------\n\n"
