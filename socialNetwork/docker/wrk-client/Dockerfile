FROM ubuntu:20.04
COPY . /socialNetwork
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Tijuana
RUN apt-get -y update && \
    apt-get -y install dnsutils python3 python3-pip python3-aiohttp libssl-dev libz-dev luarocks iputils-ping lynx build-essential gcc bash curl wget vim && \
    pip3 install asyncio && \
    pip3 install aiohttp && \
    luarocks install luasocket
RUN cd /socialNetwork/wrk2 && make clean && make
WORKDIR /socialNetwork
