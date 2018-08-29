FROM ubuntu:trusty

MAINTAINER JT <crossmaya@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/nginx.list

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/php.list

#install pages
RUN apt-get update && \
    apt-get -y --force-yes --no-install-recommends install \
    supervisor \
    nginx \    
    php5.6-cli \
    php5.6-fpm \
    php5.6-common \
    php5.6-mysql \
    php5.6-curl \
    php5.6-mbstring \
    php5.6-mcrypt \
    php5.6-gd

# configure nginx 
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# configure php
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/5.6/fpm/php-fpm.conf
RUN perl -pi -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/allow_url_fopen = Off/allow_url_fopen = On/g' /etc/php5.6/fpm/php.ini
RUN perl -pi -e 's/expose_php = On/expose_php = Off/g' /etc/php/5.6/fpm/php.ini

# clean
RUN apt-get autoclean && apt-get -y autoremove

RUN echo "<?php phpinfo();" >> /var/www/html/index.php

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www"]

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 备份默认的nginx配置文件。
RUN cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

COPY nginx.conf /etc/nginx/sites-available/default

RUN mkdir /run/php

# NGINX ports
EXPOSE 80 443

CMD ["/usr/bin/supervisord"]