FROM amazonlinux:latest

RUN yum -y update
RUN yum -y install \
	wget \
	tar \
	java-1.8.0-openjdk \
	ImageMagick \ 
	ImageMagick-devel \
	fontconfig \
	freetype \ 
	freetype-devel \ 
	fontconfig-devel \
	libstdc++

# Install language pack -- Start
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
# Install language pack -- End

# Setup codeBeamer - Start 
COPY rootfs /
RUN chmod -R g+rwX /CB
RUN mv /configuration.template /CB/config/
RUN chmod +x /CB/bin/cb
RUN chmod +x /CB/bin/startup
RUN chmod +x /CB/bin/stop
RUN chmod +x /CB/bin/status 
# Setup codeBeamer - End 

# Install phantomjs - Start
ADD rootfs/phantomjs-2.1.1.tar.gz /opt/phantomjs/
RUN ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs
RUN phantomjs /opt/phantomjs/examples/hello.js
# Install phantomjs - End  

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
