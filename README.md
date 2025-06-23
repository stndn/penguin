# penguin

Ubuntu server configuration files, applicable for Ubuntu 24.04.

All the files should go to their respective directory in the system.


### Extras

Additional scripts as follows:
1. [`01-base-setup.sh`][url-script1] is to set up system-wide extra stuffs as `root`
2. [`02-extra-setup.sh`][url-script2] is to set up personal extra stuffs as regular user


### TODO

Please note that the scripts and manual steps required for server setup are temporary.

The manual setup processes are to be replaced by either [Ansible][url-ansible] or [Terraform][url-terraform].


<!-- Links -->
[url-script1]: scripts/01-base-setup.sh
[url-script2]: scripts/02-extra-setup.sh
[url-ansible]: https://www.ansible.com/
[url-terraform]: https://www.terraform.io/
