FROM alpine:3.9


LABEL maintainer="David Xiao   github.com/davxiao"


# Install nginx and some extra common tools
RUN apk update && apk upgrade && apk add --no-cache --update nginx openssh bash dumb-init curl jq py2-pip tcpdump git sshfs groff tzdata && \
    mkdir -p /website_files/ && \
    mkdir -p /run/nginx && \
    chown -R nginx:www-data /website_files && \
# forward request and error logs to docker log collector
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log && \
	mkdir -p /root/.ssh && \
	rm -rf /var/cache/apk/* /tmp/*


# Install AWS CLI and yq
RUN pip --no-cache-dir install --upgrade awscli yq

# Deploy the public key file
COPY id_ed25519.pub /root/.ssh/authorized_keys
COPY index.html /website_files/
COPY nginx.conf /etc/nginx/
# Put whatever commands you want the docker to run at boot time into bootstrap.sh 
COPY bootstrap.sh /root/
RUN chmod +x /root/bootstrap.sh

# If you need to build something from scrach and drop all the deps afterwards 
# so as to minimize the size of final image, use below commands
#RUN apk add --no-cache --virtual .build-deps <<any-extra-pkgs-you-need-for-build>>
#do some build here, then ...
#RUN apk del .build-deps


# Since alpine sshd does not support UsePAM, root account must be 
# enabled in /etc/shadow file so that sshd accepts root-login
RUN sed -i s/root:!/"root:*"/g /etc/shadow


# Disable SSH password auth and allow only public key auth
RUN ssh-keygen -A
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin without-password/" /etc/ssh/sshd_config
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config

# Those env are not exported to the shell as it is not running as PID 1
# so those must be exported manually to allow AWS CLI work properly
RUN echo 'export $(strings /proc/1/environ | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)' >> /etc/profile.d/ash-profile.sh
RUN echo 'export $(strings /proc/1/environ | grep AWS_EXECUTION_ENV)' >> /etc/profile.d/ash-profile.sh
RUN echo 'export $(strings /proc/1/environ | grep ECS_CONTAINER_METADATA_URI)' >> /etc/profile.d/ash-profile.sh


# Expose ports for nginx
EXPOSE 80
# Expose ports for SSH
EXPOSE 22


ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Only one CMD in Dockerfile
CMD ["bash", "-c", "/root/bootstrap.sh && nginx -g \"daemon off;\""]