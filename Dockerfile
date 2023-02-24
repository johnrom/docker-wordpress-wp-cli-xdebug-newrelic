# Adds New Relic support to 
# Docker Hub: https://registry.hub.docker.com/r/johnrom/docker-wordpress-wp-cli-xdebug-newrelic
# Github Repo: https://github.com/johnrom/docker-wordpress-wp-cli-xdebug-newrelic
FROM johnrom/docker-wordpress-wp-cli-xdebug:5.5.1-php7.4-apache
LABEL maintainer=docker@johnrom.com

RUN apt-get update && apt-get install -y gnupg

RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee /etc/apt/sources.list.d/newrelic.list \
    && curl -Ls https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y newrelic-php5

# Add sudo in order to run wp-cli as the www-data user
RUN NR_INSTALL_SILENT=1 newrelic-install install

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
