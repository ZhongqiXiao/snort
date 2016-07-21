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
RUN cd ~/snort_src/ && apt-get install bison flex -y && wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz && tar -zxvf daq-2.0.6.tar.gz && cd daq-2.0.6/ && ./configure && make && make install
RUN apt-get install zlib1g-dev liblzma-dev openssl libssl-dev -y

RUN cd ~/snort_src/ && wget https://www.snort.org/downloads/snort/snort-2.9.8.3.tar.gz && tar -zxvf snort-2.*.tar.gz && cd snort-2.* && ./configure --enable-sourcefire && make && make install

RUN ldconfig
RUN ln -s /usr/local/bin/snort /usr/sbin/snort

RUN groupadd snort
RUN useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

# Create necessary files and folders
RUN mkdir -p /etc/snort/rules/iplists
RUN mkdir /etc/snort/preproc_rules
RUN mkdir /usr/local/lib/snort_dynamicrules
RUN mkdir /etc/snort/so_rules
RUN mkdir -p /var/log/snort/archived_logs
RUN touch /etc/snort/rules/iplists/black_list.rules
RUN touch /etc/snort/rules/iplists/white_list.rules
RUN touch /etc/snort/rules/local.rules
RUN touch /etc/snort/sid-msg.map

# Set permissions in the necessary files and folders
RUN chmod -R 5775 /etc/snort
RUN chmod -R 5775 /var/log/snort
RUN chmod -R 5775 /usr/local/lib/snort_dynamicrules
RUN chown -R snort:snort /etc/snort
RUN chown -R snort:snort /var/log/snort
RUN chown -R snort:snort /usr/local/lib/snort_dynamicrules

# Copy configuration files
RUN cd ~/snort_src/snort-2.*/etc/ && cp *.conf* /etc/snort && cp *.map /etc/snort && cp *.dtd /etc/snort && cd ~/snort_src/snort-2.*/src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/ && cp * /usr/local/lib/snort_dynamicpreprocessor/

ADD snort.conf /etc/snort
RUN cd / && snort -T -i eth0 -c /etc/snort/snort.conf
RUN echo 'mysql-server mysql-server-5.7/root_password password your_password' | debconf-set-selections && echo 'mysql-server mysql-server-5.7/root_password_again password Pilote2016' | debconf-set-selections
RUN apt-get install mysql-server
RUN apt-get install libmysqlclient-dev mysql-client autoconf libtool -y
