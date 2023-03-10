# Adds New Relic support to 
# Docker Hub: https://registry.hub.docker.com/r/johnrom/docker-wordpress-wp-cli-xdebug-newrelic
# Github Repo: https://github.com/johnrom/docker-wordpress-wp-cli-xdebug-newrelic
FROM johnrom/docker-wordpress-wp-cli-xdebug:6.1.1-php8.1-apache
LABEL maintainer=docker@johnrom.com

RUN apt-get update && apt-get install -y gnupg cron

RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee /etc/apt/sources.list.d/newrelic.list \
    && curl -Ls https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y newrelic-php5

# Add sudo in order to run wp-cli as the www-data user
RUN NR_INSTALL_SILENT=1 newrelic-install install

RUN docker-php-ext-enable newrelic

RUN (crontab -l 2>/dev/null; echo "* * * * * curl http://localhost/wp-cron.php?doing_wp_cron > /dev/null 2>&1") | crontab -

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Cheating -- we should really run a separate WP Cron container which will ping WP and have its own uptime.
# http://www.idein.it/joomla/14-docker-php-apache-with-crontab

# Create the log file to be able to run tail
RUN mkdir -p /var/log/cron

# Add a command to base-image entrypont scritp
RUN sed -i 's/^exec /service cron start\n\nexec /' /usr/local/bin/apache2-foreground
