FROM ubuntu:trusty
MAINTAINER Eric VILLARD <dev@eviweb.fr>
LABEL version="0.1.0"
LABEL description="Gitolite ready to go..."

# install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get -yq install \
        git \
        ssh-client \
        openssh-server \
        libjson-perl \
        libjson-xs-perl

# prepare sudoers
RUN echo "Cmnd_Alias SSHD = /usr/sbin/service ssh *" > /etc/sudoers.d/01-aliases
RUN echo "%ssh-users ALL=(ALL) NOPASSWD: SSHD" > /etc/sudoers.d/20-ssh-users
RUN chmod 440 /etc/sudoers.d/*
RUN addgroup ssh-users

# prepare openssh server runtime environment
RUN mkdir -p /var/run/sshd

# create git user
RUN adduser \
    --home /home/git \
    --shell /bin/bash \
    --disabled-password \
    --gecos "" \
    git
RUN adduser git ssh-users

# fix locale issue
RUN sed -i 's/^AcceptEnv/# AcceptEnv/g' /etc/ssh/sshd_config

# become git
USER git
ENV HOME /home/git
ENV USER git
WORKDIR /home/git

# prepare environment
RUN mkdir .ssh bin services \
    && touch .ssh/authorized_keys
ENV PATH $HOME/bin:$PATH
COPY .user-keys/*.pub .ssh/
COPY src/bin/*.sh bin/
COPY src/services/*.sh services/
USER root
RUN chmod -R +x bin/* services/*
RUN ln -s run.sh bin/run
RUN chown -R git: bin services
USER git

# install gitolite
RUN bin/gitolite-setup.sh

# start needed services
ENTRYPOINT ["run"]
