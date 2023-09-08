#/bin/bash

# Set timezone
timedatectl set-timezone Asia/Kuala_Lumpur

# Set timestamp
TIMESTAMP=$(date "+%Y%m%d")

# Update packages
echo "Updating packages ..."
apt update && apt -y upgrade

# Set default editor to vim
echo "Change default editor ..."
update-alternatives --set editor /usr/bin/vim.basic

# Ask password for every sudo commands
echo "Always ask password for sudo ..."
sed -i -e 's/^\(Defaults\s\+\)env_reset$/\1env_reset,timestamp_timeout=0/' /etc/sudoers

# Temporarily disable ipv6
echo "Disable ipv6 ..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Update vim to 9.0 (requires ipv6 to be disabled)
echo "Update vim ..."
add-apt-repository ppa:jonathonf/vim
apt update && apt install -y vim

# Install extras
echo "Installing extra packages ..."
apt install -y net-tools postgresql-client libpq-dev python3-pip

# Clean up unused packages
apt -y autoremove


# Install docker and docker-compose

# 1. Install dependencies
apt -y install apt-transport-https ca-certificates curl software-properties-common

# 2. Get the GPG for docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 3. Add docker repository to APT sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Update packages and check the package to be installed
apt update && apt-cache policy docker-ce

# 5. Install docker
apt -y install docker-ce

# 6. Give permission for user to execute docker without root. Replace with the actual username
usermod -aG docker username


# Add system-wide history with timestamp
grep HISTTIMEFORMAT /etc/bash.bashrc | grep -v grep
HTF=$?
if [[ $HTF -eq 1 ]]; then
  cp -p /etc/bash.bashrc /etc/bash.bashrc.${TIMESTAMP}.bak
  echo '' >> /etc/bash.bashrc
  echo 'HISTTIMEFORMAT="%F %T "' >> /etc/bash.bashrc
fi

