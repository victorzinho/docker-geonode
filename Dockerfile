FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN apt-get upgrade -y
RUN add-apt-repository -y ppa:geonode/stable
RUN apt-get -y update
RUN apt-get -y install geonode
RUN geonode create superuser
RUN geonode-updateip

EXPOSE 80
