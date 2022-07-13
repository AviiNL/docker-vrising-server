FROM debian:bullseye-slim

ENV DATA_DIR="/serverdata"
ENV SCRIPTS_DIR="${DATA_DIR}/scripts"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"

ENV APP_ID=1829350
ENV AUTO_UPDATE=true
ENV ENABLE_BEPINEX=false

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN  echo "deb http://deb.debian.org/debian bullseye contrib non-free" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y install --no-install-recommends wget locales procps && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt -y install gnupg2 software-properties-common && \
	wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
	echo " deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list.d/wine.list && \
	apt-get update && \
	apt -y install --no-install-recommends winehq-stable && \
	apt-get -y --purge remove software-properties-common gnupg2

RUN apt-get update && \
	apt-get -y install --no-install-recommends curl unzip jq lib32gcc-s1 lib32stdc++6 screen xvfb winbind xauth && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir $DATA_DIR && \
	mkdir $STEAMCMD_DIR && \
	mkdir $SERVER_DIR && \
	ulimit -n 2048

ADD /scripts/ $SCRIPTS_DIR/

RUN groupadd -g 1000 steam && \
	useradd -m -u 1000 -s /bin/bash -g 1000 -c "User for steam" steam && \
	chown -R steam:steam $DATA_DIR

RUN chmod -R 770 $SCRIPTS_DIR && \
	chmod +x $SCRIPTS_DIR/*.sh

#Server Start
ENTRYPOINT "$SCRIPTS_DIR/bootstrap.sh"
