# Web Server and More

## Nginx - Web Server

For our server, we will install the latest Nginx available for [Ubuntu 22.04][url-ubuntu-2204] instead of the version that comes with the OS. As such, we will need to start by adding the appropriate repository before our installation.

### Installation summary

(All steps assume `root` user)

Summary of [Nginx installation][url-nginx-install]:

1. Add the Nginx repository to `/etc/apt/sources.list.d/nginx.list`:
    ```
    deb https://nginx.org/packages/ubuntu/ jammy nginx
    deb-src https://nginx.org/packages/ubuntu/ jammy nginx
    ```

1. Install Nginx using `apt`:
    ```
    apt update && apt install -y nginx
    ```

1. Enable Nginx to auto start:
    ```
    systemctl enable nginx
    ```

1. Start Nginx:
    ```
    systemctl start nginx
    ```

### Notes

If you encounter `GPG error` during installation:
```
W: GPG error: https://nginx.org/packages/ubuntu jammy InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY ABF5BD827BD9BF62
```

You need to add the key before proceeding with installation:
```
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
apt update && apt install -y nginx
```


## SSL Certificates

For the SSL certificates, we will use the free SSL certificate provided by [Certbot][url-certbot].

### Installation summary

(All steps assume `root` user)

Summary of [Certbot installation][url-certbot-install]:

(Note: The documentation is for Ubuntu 20.04, but it works for 22.04 as well)

1. Ensure that `snapd` is installed

1. Run the command to install Certbot
    ```
    snap install --classic certbot
    ```

1. Ensure at least one [Nginx configuration files][url-nginx-samples] is available. The file is usually located under `/etc/nginx/conf.d/`, and has filename extension `.conf`

1. Let Certbot get the SSL certificate and configure Nginx for us (specify the domain with `-d` option):
    ```
    certbot --nginx -d example.com
    ```
    Alternatively, just get a certificate and modify Nginx configuration files manually:
    ```
    certbot certonly --nginx -d example.com
    ```

1. Once done, reload Nginx and try to open the website in your web browser. It should redirect to https by default
    ```
    nginx -s reload
    ```


### Notes

It is recommended to disable the default Nginx configuration file at `/etc/nginx/conf.d/default.conf`. The simplest way is to rename the file to a different extension, since the default `/etc/nginx/nginx.conf` includes all the configuration files under `/etc/nginx/conf.d/*.conf`:
```
mv /etc/nginx/conf.d/default.conf{,.bak}
```


<!-- Links -->
[url-ubuntu-2204]: https://www.releases.ubuntu.com/jammy/ "Ubuntu 22.04 - Jammy Jellyfish"
[url-nginx-install]: https://www.nginx.com/resources/wiki/start/topics/tutorials/install/ "Nginx installation guide"
[url-certbot]: https://certbot.eff.org/ "Certbot"
[url-certbot-install]: https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal "Certbot instruction"
[url-nginx-samples]: /webserver/nginx-conf.d/ "Sample Nginx configuration files"
