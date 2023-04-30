FROM ubuntu:18.04
MAINTAINER hflocki78@gmail.com
EXPOSE 8080 5901
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt-get install -y novnc
RUN apt-get install -y tightvncserver websockify
RUN apt-get install -y gnupg net-tools wget curl chromium-browser firefox openssh-client git
ENV USER root

COPY start.sh /start.sh
RUN chmod a+x /start.sh

RUN useradd -ms /bin/bash user
RUN mkdir /.novnc
RUN chown user:user /.novnc

COPY config /home/user
RUN chown -R user:user /home/user

#WORKDIR /tmp
RUN apt-get -y install gedit nano
USER user

WORKDIR /.novnc
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $PWD
RUN mkdir /.novnc/utils/websockify
RUN wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C /.novnc/utils/websockify
RUN ln -s vnc.html index.html

USER 0
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=dummy
RUN dpkg --add-architecture i386
RUN apt-get update
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-get install -y software-properties-common
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
RUN apt-get update
RUN apt-get install -y --install-recommends wine1.6 

# install gecko
RUN mkdir -p /usr/share/wine/gecko \
		&& curl -SL http://dl.winehq.org/wine/wine-gecko/2.40/wine_gecko-2.40-x86.msi -o /usr/share/wine/gecko/wine_gecko-2.40-x86.msi \
		&& curl -SL http://dl.winehq.org/wine/wine-gecko/2.40/wine_gecko-2.40-x86_64.msi -o /usr/share/wine/gecko/wine_gecko-2.40-x86_64.msi \
		&& chmod +x /usr/share/wine/gecko/*.msi \
# install mono
&&  mkdir -p /usr/share/wine/mono \
		&& curl -SL 'http://sourceforge.net/projects/wine/files/Wine%20Mono/4.5.6/wine-mono-4.5.6.msi/download' -o /usr/share/wine/mono/wine-mono-4.5.6.msi\
		&& chmod +x /usr/share/wine/mono/wine-mono-4.5.6.msi \
# install winetricks
	&& curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks \
		&& chmod +x /usr/local/bin/winetricks \
# cleanup
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/user

CMD ["sh","/start.sh"]
