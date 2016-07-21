FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install openssh-server
RUN apt-get install ethtool
RUN ethtool -K eth0 gro off
RUN ethtool -K eth0 lro off
RUN ethtool -k ens160 | grep receive-offload
