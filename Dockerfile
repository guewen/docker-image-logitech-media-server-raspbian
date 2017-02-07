FROM resin/rpi-raspbian
MAINTAINER Lars Kellogg-Stedman <lars@oddbit.com>

ENV SQUEEZEBOX_VERSION 7.9.0
ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGE_VERSION_URL=http://www.mysqueezebox.com/update/?version=${SQUEEZEBOX_VERSION}&revision=1&geturl=1&os=deb

RUN apt-get update && \
	apt-get -y --force-yes install curl wget faad flac lame sox libio-socket-ssl-perl tzdata iproute \
              libjpeg8 libpng12-0 libgif4 libexif12 && \
	url=$(curl "$PACKAGE_VERSION_URL" | sed 's/_all\.deb/_amd64\.deb/') && \
	curl -Lsf -o /tmp/logitechmediaserver.deb $url && \
	dpkg -i /tmp/logitechmediaserver.deb && \
	rm -f /tmp/logitechmediaserver.deb && \
	apt-get clean

RUN mkdir -p /config/etc && mv /etc/timezone /config/etc/ && ln -s /config/etc/timezone /etc/
RUN echo "Europe/Zurich" > /config/etc/timezone

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090

COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh
ENTRYPOINT ["/entrypoint.sh"]

