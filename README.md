# penguin

Server configuration files, applicable for [Debian 12.11][url-debian] and [Ubuntu 24.04][url-ubuntu].

All the files should go to their respective directory in the system.


### Additional requirements for Debian 12.11

Install `git` to clone this repository and `vim` to use different efault text editor.

```
apt update && apt install -y git vim
```

### Extras

Additional scripts as follows:
1. [`01-base-setup.sh`][url-script1] is to set up system-wide extra stuffs as `root`
1. [`02-extra-setup.sh`][url-script2] is to set up personal extra stuffs as regular user
1. [`03-docker-debian.sh`][url-script3] is to set up Docker on Debian system as `root`
1. [`04-docker-debian.sh`][url-script4] is to set up Docker on Ubuntu system as `root`


### TODO

Please note that the scripts and manual steps required for server setup are temporary.

The manual setup processes are to be replaced by either [Ansible][url-ansible] or [Terraform][url-terraform].


<!-- Links -->
[url-script1]: scripts/01-base-setup.sh
[url-script2]: scripts/02-extra-setup.sh
[url-script3]: scripts/03-docker-debian.sh
[url-script4]: scripts/04-docker-ubuntu.sh
[url-debian]: https://www.debian.org/News/2025/20250517
[url-ubuntu]: https://discourse.ubuntu.com/t/ubuntu-24-04-lts-noble-numbat-release-notes/39890
[url-ansible]: https://www.ansible.com/
[url-terraform]: https://www.terraform.io/
