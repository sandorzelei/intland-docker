FROM alpine:latest

RUN apk add --no-cache \ 
      imagemagick \
      openjdk8-jre-base=8.181.13-r0 \
      curl \
      procps \
      ca-certificates \
      wget

# Install language pack
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-bin-2.28-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-i18n-2.28-r0.apk && \
    apk add glibc-bin-2.28-r0.apk glibc-i18n-2.28-r0.apk glibc-2.28-r0.apk

RUN /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN wget -q https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -P /tmp &&\
 bzip2 -d /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 &&\
 tar -xf /tmp/phantomjs-2.1.1-linux-x86_64.tar -C /usr/local &&\
 rm /tmp/phantomjs-2.1.1-linux-x86_64.tar &&\
 ln -s /usr/local/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs


COPY rootfs /
RUN chmod -R g+rwX /CB
RUN mv /configuration.template /CB/config/
RUN chmod +x endpoint.sh
RUN chmod +x run.sh

EXPOSE 8080

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f http://localhost:8080/cb/hc/ping.spr || exit 1

VOLUME /CB/repository/docs 
VOLUME /CB/repository/wiki
VOLUME /CB/repository/search

USER 1001

WORKDIR /
ENTRYPOINT [ "/endpoint.sh" ]
CMD [ "/run.sh" ]
