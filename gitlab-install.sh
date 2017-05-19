#!/bin/bash
# -- --
# prerequisites
# 	redis-install
#	postgres-install
# optional
#	ldap-install
#	keycloack-install
# -- --
# -- --
GITLAB_VERSION=8.3.2
RUBY_VERSION=2.3
GOLANG_VERSION=1.6.3
GITLAB_SHELL_VERSION=5.0.2
GITLAB_WORKHORSE_VERSION=1.4.3
GITLAB_PAGES_VERSION=0.4.0
GITLAB_USER="git"
GITLAB_HOME="/home/git"
GITLAB_LOG_DIR="/var/log/gitlab"
GITLAB_CACHE_DIR="/etc/docker-gitlab"
RAILS_ENV=production
# -- --
# optional parameters
# -- --
GITLAB_INSTALL_DIR="${GITLAB_HOME}/gitlab"
GITLAB_SHELL_INSTALL_DIR="${GITLAB_HOME}/gitlab-shell"
GITLAB_WORKHORSE_INSTALL_DIR="${GITLAB_HOME}/gitlab-workhorse"
GITLAB_PAGES_INSTALL_DIR="${GITLAB_HOME}/gitlab-pages"
GITLAB_DATA_DIR="${GITLAB_HOME}/data"
GITLAB_BUILD_DIR="${GITLAB_CACHE_DIR}/build"
GITLAB_RUNTIME_DIR="${GITLAB_CACHE_DIR}/runtime"
# -- --
# install all dependencies
# -- --
sudo apt-get install curl openssh-server ca-certificates postfix

#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
# && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
# && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
# && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
# && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
# && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
# && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
# && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
# && wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
# && echo 'deb https://deb.nodesource.com/node_7.x trusty main' > /etc/apt/sources.list.d/nodesource.list \
# && wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg  | apt-key add - \
# && echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list \
# && apt-get update \
# && apt-get install -y logrotate locales curl \
#      nginx openssh-server postgresql-client redis-tools \
#      git-core ruby${RUBY_VERSION} python2.7 python-docutils nodejs yarn gettext-base \
#      libpq5 zlib1g libyaml-0-2 libssl1.0.0 \
#      libgdbm3 libreadline6 libncurses5 libffi6 \
#      libxml2 libxslt1.1 libcurl3 libicu52 \
# && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
# && locale-gen en_US.UTF-8 \
# && dpkg-reconfigure locales \
# && gem install --no-document bundler \
# && rm -rf /var/lib/apt/lists/*
## -- --
## build gitlab
## -- --
#SCRIPT_DIR=$(dirname $(readlink -f $0))
#echo "script dir: $SCRIPT_DIR"
#. ${SCRIPT_DIR}/gitlab-build.sh
