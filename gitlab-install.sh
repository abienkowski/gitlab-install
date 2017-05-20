#!/bin/bash
# -- --
# prerequisites
# 	redis-install
#	postgres-install
# optional
#	ldap-install
#	keycloack-install
# -- --
# install options 
# -- --
RUN_UPDATE_AND_UPGRADE=false
INSTALL_GO=false
INSTALL_DEPS=false
INSTALL_SYSTEM_USER=false
INSTALL_DB_POSTGRES=false
INSTALL_DB_REDIS=false
INSTALL_GITLAB=true
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
# If you want to use Kerberos for user authentication, then install libkrb5-dev:
# -- --
AUTH_KERBEROS=false
# -- --
# run update and upgrade
# -- --
if ( $RUN_UPDATE_AND_UPGRADE ); then
  apt-get update && apt-get upgrade -y
fi
# -- --
# install all dependencies
# -- --
# Install the required packages (needed to compile Ruby and native extensions to Ruby gems)
# -- --
DEPENDENCIES="build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev logrotate python-docutils pkg-config cmake nodejs"
if ( $AUTH_KERBEROS ); then
  DEPENDENCIES="$DEPENDENCIES libkrb5-dev"
  echo "Adding libkrb5-dev for Kerberos support..."
fi
# -- --
# install all dependencies
# -- --
if ( $INSTALL_DEPS ); then
  apt-get install -y $DEPENDENCIES
fi
# -- --
# install go
# -- --
if ( $INSTALL_GO ); then
  # -- --
  # lookup the checksum value for specific release here: https://golang.org/dl/
  # -- --
  curl -O --progress https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz
  echo "cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb go${GOLANG_VERSION}.linux-amd64.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz
  ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/
  rm go${GOLANG_VERSION}.linux-amd64.tar.gz
fi
# -- --
# add system user
# -- --
if ( $INSTALL_SYSTEM_USER ); then
  echo -n "Adding system user ${GITLAB_USER}..."
  adduser --disabled-login --gecos 'GitLab' $GITLAB_USER
  echo "done"
fi
# -- --
# install postgres
# -- --
if ( $INSTALL_DB_POSTGRES ); then
  # Install the database packages
  apt-get install -y postgresql postgresql-client libpq-dev
  # Login to PostgreSQL
  sudo -u postgres bash -c "psql -c \"CREATE USER git CREATEDB;\""
  sudo -u postgres bash -c "psql -c \"CREATE DATABASE gitlabhq_production OWNER git;\""
  echo -n "Looking for the created database ... found -> "
  sudo -u git -H bash -c "psql -lqt | cut -d \| -f 1 | grep -w gitlabhq_production"
fi
# -- --
# install redis
# -- --
if ( $INSTALL_DB_REDIS ); then
  # Add git to the redis group
  usermod -aG gitlab-redis $GITLAB_USER
fi
# -- --
# clone gitlab
# -- --
if ( $CLONE_GITLAB_VERSION ); then
  cd $GITLAB_USER_HOME
  # -- TODO: change 8-3-stable to be driven from the configuraiton above
  git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 8-3-stable gitlab
fi
# -- --
# install gitlab
# -- --
if ( $INSTALL_GITLAB ); then
  # gitlab home directory
# Go to GitLab installation folder
cd /home/git/gitlab

# Copy the example GitLab config
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

# Update GitLab config file, follow the directions at top of file
sudo -u git -H editor config/gitlab.yml

# Copy the example secrets file
sudo -u git -H cp config/secrets.yml.example config/secrets.yml
sudo -u git -H chmod 0600 config/secrets.yml

# Make sure GitLab can write to the log/ and tmp/ directories
sudo chown -R git log/
sudo chown -R git tmp/
sudo chmod -R u+rwX,go-w log/
sudo chmod -R u+rwX tmp/

# Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
sudo chmod -R u+rwX tmp/pids/
sudo chmod -R u+rwX tmp/sockets/

# Make sure GitLab can write to the public/uploads/ directory
sudo chmod -R u+rwX  public/uploads

# Change the permissions of the directory where CI build traces are stored
sudo chmod -R u+rwX builds/

# Change the permissions of the directory where CI artifacts are stored
sudo chmod -R u+rwX shared/artifacts/

# Copy the example Unicorn config
sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb

# Find number of cores
nproc

# Enable cluster mode if you expect to have a high load instance
# Set the number of workers to at least the number of cores
# Ex. change amount of workers to 3 for 2GB RAM server
sudo -u git -H editor config/unicorn.rb

# Copy the example Rack attack config
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# Configure Git global settings for git user, used when editing via web editor
sudo -u git -H git config --global core.autocrlf input

# Configure Redis connection settings
sudo -u git -H cp config/resque.yml.example config/resque.yml

# Change the Redis socket path if you are not using the default Debian / Ubuntu configuration
sudo -u git -H editor config/resque.yml
  
fi

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
