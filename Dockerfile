FROM debian:bullseye

RUN sed -i -e "s/ main[[:space:]]*\$/ main contrib non-free/" /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt update
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN apt install -y curl libcap2 steamcmd

COPY ./run_server.sh /run_server.sh
WORKDIR /server

# Stable:
# STEAM_APP_ID=223350
#
# Experimental:
# STEAM_APP_ID=1042420
ENV STEAM_APP_ID=1042420

VOLUME ["/server"]
ENTRYPOINT ["/run_server.sh"]