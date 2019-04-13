# docker-nginx-sshd
A minimal Docker image with sshd and nginx service. The following packages are included:
* nginx
* openssh
* bash
* dumb-init
* python3
* tcpdump
* socat
* nfs-utils
* tzdata
* curl
* git
* jq
* yq
* AWS cli

This image is ONLY intended for non-prod use.

For security reasons, the sshd is configured to allow only publickey access. You will need to place your own public key file `id_rsa.pub` in the folder. If the private key is compromised, the container must be stopped immediately to prevent from unauthorized access.


TODO:
- Add a script that gracefully export env variables from PID 1 to the shell
- Re-write Dockerfile using multistage-build. https://docs.docker.com/develop/develop-images/multistage-build/
