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
    && git clone --depth=1 https://github.com/PGYER/codefever.git /apps/codefever \
    && cd /apps/codefever/misc \
    && sed -i "s/\/data\/www\/codefever-community/\/apps\/codefever/" codefever-service-template initailize_container.sh install.sh nginx.conf-template update.sh docker/docker-entrypoint.sh docker/supervisor-codefever-http-gateway.conf docker/supervisor-codefever-modify-authorized-keys.conf docker/vhost.conf-template

# Config
RUN cd /apps/codefever/misc/docker \
    && cp vhost.conf-template /opt/docker/etc/nginx/vhost.conf \
    && cp supervisor-codefever-modify-authorized-keys.conf /opt/docker/etc/supervisor.d/codefever-modify-authorized-keys.conf \
    && cp supervisor-codefever-http-gateway.conf /opt/docker/etc/supervisor.d/codefever-http-gateway.conf \
    && cd /apps/codefever \
    && cp misc/codefever-service-template /etc/init.d/codefever \
    && cp config.template.yaml config.yaml \
    && cp env.template.yaml env.yaml \
    && chmod 0777 config.yaml env.yaml \
    && chmod +x /opt/docker/etc/supervisor.d/codefever-modify-authorized-keys.conf \
    && chmod +x /opt/docker/etc/supervisor.d/codefever-http-gateway.conf

# Gateways
RUN cd /apps/codefever/http-gateway \
    && go get gopkg.in/yaml.v2 \
    && go build main.go \
    && cd /apps/codefever/ssh-gateway/shell \
    && go get gopkg.in/yaml.v2 \
    && go build main.go

# PHP
RUN mkdir /usr/local/php/bin \
    && ln -s /usr/local/bin/php /usr/local/php/bin/php \
    && cd /apps/codefever/application/libraries/composerlib/ \
    && php ./composer.phar install

# Entrypoint
RUN cp /apps/codefever/misc/docker/docker-entrypoint.sh /opt/docker/provision/entrypoint.d/20-codefever.sh

# Storage
RUN cd /apps/codefever \
    && useradd -rm git \
    && mkdir application/logs \
    && chown -R git:git application/logs \
    && chmod -R 0777 application/logs  \
    && mkdir file-storage \
    && chown -R git:git file-storage \
    && chmod -R 0777 git-storage \
    && chown -R git:git misc \
    && mkdir storage-template \
    && mv git-storage storage-template/git-storage \
    && mv file-storage storage-template/file-storage \
    && mv application/logs storage-template/logs \
    && cp /usr/bin/init-storage.sh /opt/docker/provision/entrypoint.d/19-init-storage.sh
    
# Cron
RUN docker-cronjob '* * * * *  sh /apps/codefever/application/backend/codefever_schedule.sh'

EXPOSE 80

# Persistence directory
VOLUME [ "/data"]