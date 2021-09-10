FROM debian:bullseye

RUN apt update
RUN apt install -y curl libcap2

WORKDIR /server
VOLUME ["/server"]