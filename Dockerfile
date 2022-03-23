FROM ubuntu:20.04

LABEL AboutImage "Ubuntu20.04_Chromium_NoVNC"

LABEL Maintainer "Apoorv Vyavahare <apoorvvyavahare@pm.me>"

ARG DEBIAN_FRONTEND=noninteractive

#VNC Server Password
ENV	VNC_PASS="samplepass" \
#VNC Server Title(w/o spaces)
	VNC_TITLE="Chromium" \
#VNC Resolution(720p is preferable)
	VNC_RESOLUTION="1280x720" \
#VNC Shared Mode (0=off, 1=on)
	VNC_SHARED=0 \
#Local Display Server Port
	DISPLAY=:0 \
#NoVNC Port
	NOVNC_PORT=$PORT \
	PORT=8080 \
#Locale
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="Europe/London" \
	TARGET_APP="https://example.com"

COPY rootfs/ /

SHELL ["/bin/bash", "-c"]

RUN	apt-get update && \
	apt-get install -y websockify tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer net-tools tzdata ca-certificates supervisor curl wget python3 python3-pip sed unzip openbox libnss3 libgbm-dev libasound2 && \
#Chromium
	wget https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/938008/chrome-linux.zip -P /tmp && \
	unzip /tmp/chrome-linux.zip -d /opt && \
#noVNC
	mkdir /root/.vnc && echo $VNC_PASS | vncpasswd -f > /root/.vnc/passwd && chmod 0600 /root/.vnc/passwd && \
#TimeZone
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
#Python MOdules
	pip3 install requests && \
#Wipe Temp Files
	rm -rf /var/lib/apt/lists/* && \ 
	apt-get remove -y wget python3-pip unzip && \
	apt-get -y autoremove && \
	apt-get clean && \
	rm -rf /tmp/*

ENTRYPOINT ["supervisord", "-l", "/var/log/supervisord.log", "-c"]

CMD ["/config/supervisord.conf"]
