FROM webdevops/php-nginx:7.4

LABEL maintainer "Yefori yefori.go@gmail.com"

ENV OS_ARCH="amd64" \
    OS_NAME="debian-10" \
    HOME_PAGE="https://codefever.cn/"

COPY debian/prebuildfs /

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

ARG IS_CHINA="true"
ENV MIRROR=${IS_CHINA}

RUN install_packages curl wget zip unzip s6 pwgen cron libyaml-dev git golang-go zip sendmail mailutils mariadb-client vim

RUN pecl install yaml \
    && docker-php-ext-enable yaml

# Nodejs
RUN cd /usr/local \
    && wget https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz \
    && tar -xf node-v16.15.1-linux-x64.tar.xz \ 
    && rm -rf node-v16.15.1-linux-x64.tar.xz \
    && mv node-v16.15.1-linux-x64 node \
    && ln -s /usr/local/node/bin/node /usr/local/bin/node \
    && ln -s /usr/local/node/bin/npm /usr/local/bin/npm \
    && ln -s /usr/local/node/bin/npx /usr/local/bin/npx \
    && ln -s /usr/local/node/bin/corepack /usr/local/bin/corepack \
    && corepack enable

# SSH
RUN docker-service enable ssh && docker-service enable cron

# Install codefever
ARG VERSION
ENV APP_VER=${VERSION}
ENV EASYSOFT_APP_NAME="codefever $APP_VER"

# Copy codefever config files
COPY debian/rootfs /

# Copy codefever source code
WORKDIR /apps/codefever
RUN chown www-data.www-data /apps/codefever -R \
    && mkdir -p /data/www \
    && ln -s /apps/codefever /data/www \
    && cd /data/www \
    && git clone --depth=1 https://github.com/PGYER/codefever.git codefever-community

# Config
RUN cd /data/www/codefever-community \
    && cp misc/docker/vhost.conf-template /opt/docker/etc/nginx/vhost.conf \
    && cp misc/docker/supervisor-codefever-modify-authorized-keys.conf /opt/docker/etc/supervisor.d/codefever-modify-authorized-keys.conf \
    && cp misc/docker/supervisor-codefever-http-gateway.conf /opt/docker/etc/supervisor.d/codefever-http-gateway.conf \
    && cp misc/docker/docker-entrypoint.sh /usr/bin/entrypoint.sh \
    && cd /data/www/codefever-community/http-gateway \
    && go get gopkg.in/yaml.v2 \
    && go build main.go \
    && cd /data/www/codefever-community/ssh-gateway/shell \
    && go get gopkg.in/yaml.v2 \
    && go build main.go \
    && useradd -rm git \
    && mkdir /usr/local/php/bin \
    && ln -s /usr/local/bin/php /usr/local/php/bin/php \
    && cd /data/www/codefever-community \
    && cp misc/codefever-service-template /etc/init.d/codefever \
    && cp config.template.yaml config.yaml \
    && cp env.template.yaml env.yaml \
    && chmod 0777 config.yaml env.yaml \
    && mkdir application/logs \
    && chown -R git:git application/logs \
    && chmod -R 0777 application/logs  \
    && chmod -R 0777 git-storage \
    && mkdir file-storage \
    && chown -R git:git file-storage \
    && chown -R git:git misc \
    && chmod +x /opt/docker/etc/supervisor.d/codefever-modify-authorized-keys.conf \
    && chmod +x /opt/docker/etc/supervisor.d/codefever-http-gateway.conf \
    && cd /data/www/codefever-community/application/libraries/composerlib/ \
    && php ./composer.phar install \
    && cp /data/www/codefever-community/misc/docker/docker-entrypoint.sh /opt/docker/provision/entrypoint.d/20-codefever.sh

# Cron
RUN docker-cronjob '* * * * *  sh /data/www/codefever-community/application/backend/codefever_schedule.sh'

EXPOSE 80

# Persistence directory
VOLUME [ "/data"]