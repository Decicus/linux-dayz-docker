FROM debian:bullseye

RUN sed -i -e "s/ main[[:space:]]*\$/ main contrib non-free/" /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt update
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN apt install -y steamcmd curl libcap2

RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

WORKDIR /server
VOLUME ["/server"]