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
# Install php-ext-ioncube
# RUN . /opt/easysoft/scripts/libcomponent.sh && component_unpack "php-ext-ioncube" "11.0.1" -c 9a6ee08aa864f2b937b9a108d3ec8679ae3a5f08f92a36caf5280520432315ad

# Install su-exec
# RUN . /opt/easysoft/scripts/libcomponent.sh && component_unpack "su-exec" "0.2" --checksum 687d29fd97482f493efec73a9103da232ef093b2936a341d85969bc9b9498910

# Install render-template
# RUN . /opt/easysoft/scripts/libcomponent.sh && component_unpack "render-template" "1.0.1-10" --checksum 5e410e55497aa79a6a0c5408b69ad4247d31098bdb0853449f96197180ed65a4

# Install mysql-client
 #RUN . /opt/easysoft/scripts/libcomponent.sh && component_unpack "mysql-client" "10.5.15-20220817" -c c4f82cb5b66724dd608f0bafaac400fc0d15528599e8b42be5afe8cedfd16488

# Install wait-for-port
# RUN . /opt/easysoft/scripts/libcomponent.sh && component_unpack "wait-for-port" "1.01" -c 2ad97310f0ecfbfac13480cabf3691238fdb3759289380262eb95f8660ebb8d1

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
&& a2dismod authz_svn dav_svn \
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
&& cd /data/www/codefever-communityapplication/libraries/composerlib/ \
&& php ./composer.phar install

# Cron
RUN docker-cronjob '* * * * *  sh /data/www/codefever-community/application/backend/codefever_schedule.sh'

EXPOSE 80

# Persistence directory
VOLUME [ "/data"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
