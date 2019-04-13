# docker-nginx-sshd
A minimal Docker image with sshd and nginx service. The following packages are included:
nginx
openssh
bash
dumb-init
python3
tcpdump
socat
nfs-utils
curl
jq
git
tzdata
AWS cli

This image is ONLY intended for non-prod use.

For security reasons, the sshd is configured to allow only publickey access. You will need to have your own public key file `id_ed25519.pub` placed in the same folder. If the key is compromised, the container must be stopped immediately to prevent from unauthorized access.

Compiled images can be found at https://cloud.docker.com/repository/docker/davxiao/nginx-sshd 

TODO:
- Add a script that gracefully export env variables from PID 1 to the shell
- Re-write Dockerfile using multistage-build. https://docs.docker.com/develop/develop-images/multistage-build/
