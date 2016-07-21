FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install openssh-server
RUN apt-get -y install ethtool
# lanch after run privileged
#RUN ethtool -K eth0 gro off
#RUN ethtool -K eth0 lro off
#RUN ethtool -k ens160 | grep receive-offload
RUN apt-get install build-essential -y
RUN apt-get install libpcap-dev libpcre3-dev libdumbnet-dev -y
RUN mkdir ~/snort_src
RUN cd ~/snort_src/ && apt-get install bison flex -y && wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz && tar -zxvf daq-2.0.6.tar.gz
RUN cd daq-2.0.6/ && ./configure && make && make install
RUN apt-get install zlib1g-dev liblzma-dev openssl libssl-dev -y

RUN cd ~/snort_src/ && wget https://www.snort.org/downloads/snort/snort-2.9.8.3.tar.gz && tar -zxvf snort-2.*.tar.gz
