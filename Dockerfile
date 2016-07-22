FROM ubuntu:16.04
ENV MYSQLTMPROOT Pilote2016

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install openssh-server nano sudo
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

ADD snortconfig/snort.conf /etc/snort
RUN cd / && snort -T -i eth0 -c /etc/snort/snort.conf
RUN echo mysql-server mysql-server/root_password password $MYSQLTMPROOT | debconf-set-selections;\
  echo mysql-server mysql-server/root_password_again password $MYSQLTMPROOT | debconf-set-selections;\
  apt-get install -y mysql-server libmysqlclient-dev mysql-client autoconf libtool
RUN usermod -d /var/lib/mysql/ mysql  

# Download and install Barnyard2
RUN apt-get -y install git
RUN cd ~/snort_src/ && git clone git://github.com/firnsy/barnyard2.git && cd barnyard2/ && autoreconf -fvi -I ./m4
RUN ln -s /usr/include/dumbnet.h /usr/include/dnet.h
RUN ldconfig
RUN cd ~/snort_src/barnyard2 && ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu && make && make install

RUN cd ~/snort_src/barnyard2 && cp etc/barnyard2.conf /etc/snort
RUN mkdir /var/log/barnyard2
RUN chown snort.snort /var/log/barnyard2
RUN touch /var/log/snort/barnyard2.waldo
RUN chown snort.snort /var/log/snort/barnyard2.waldo

# Create the MySQL database
ADD script /tmp/
RUN service mysql start && /bin/bash /tmp/script

#Configure Barnyard2 to use the MySQL database
ADD barnyard2/barnyard2.conf /etc/snort
RUN chmod o-r /etc/snort/barnyard2.conf

#
RUN apt-get install -y libcrypt-ssleay-perl liblwp-useragent-determined-perl unzip cron
RUN cd ~/snort_src/ && wget https://github.com/finchy/pulledpork/archive/patch-3.zip && unzip patch-3.zip && cd pulledpork-patch-3 && cp pulledpork.pl /usr/local/bin/ && chmod +x /usr/local/bin/pulledpork.pl && cp etc/*.conf /etc/snort/
ADD pulledpork.conf /etc/snort/
RUN /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l
RUN (crontab -l 2>/dev/null; echo "30 02 * * * /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l") | crontab -
#RUN crontab -l > mycron && echo "30 02 * * * /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l" >> mycron && crontab mycron && rm mycron

# Web GUI for Snort Snorby
RUN apt-get install libgdbm-dev libncurses5-dev git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev -y
RUN apt-get install imagemagick apache2 libyaml-dev libxml2-dev libxslt-dev git libssl-dev -y
RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc
RUN sh -c "echo gem: --no-rdoc --no-ri > /etc/gemrc"
RUN cd ~/snort_src/ && wget http://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz && tar -zxvf ruby-2.3.0.tar.gz && cd ruby-2.3.0/ && ./configure && make && make install 
RUN gem install wkhtmltopdf
RUN gem install bundler
RUN gem install rails
RUN gem install rake --version=11.1.2

RUN cd ~/snort_src/ && git clone git://github.com/Snorby/snorby.git && cp -r snorby/ /var/www/html/ && cd /var/www/html/snorby/ && bundle install
RUN cp /var/www/html/snorby/config/database.yml.example /var/www/html/snorby/config/database.yml
ADD snorby/database.yml /var/www/html/snorby/config/

RUN cp /var/www/html/snorby/config/snorby_config.yml.example /var/www/html/snorby/config/snorby_config.yml
RUN sed -i s/"\/usr\/local\/bin\/wkhtmltopdf"/"\/usr\/bin\/wkhtmltopdf"/g /var/www/html/snorby/config/snorby_config.yml

ADD Gemfile.lock /var/www/html/snorby/
RUN cd /var/www/html/snorby/ && bundle && service mysql start && mysql_upgrade -u root -pPilote2016 --force && service mysql stop; exit 0 
RUN cd /var/www/html/snorby/ && service mysql start && bundle exec rake snorby:setup

#
ADD script2 /tmp/
RUN service mysql start && /bin/bash /tmp/script2

ADD database.yml /var/www/html/snorby/config/

# 
RUN apt-get install -y libcurl4-openssl-dev libaprutil1-dev libapr1-dev apache2-dev
RUN gem install passenger
RUN passenger-install-apache2-module --auto

RUN echo 'LoadModule passenger_module /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.0.29/buildout/apache2/mod_passenger.so' >> /etc/apache2/mods-available/passenger.load  
RUN echo 'PassengerRoot /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.0.29' >> /etc/apache2/mods-available/passenger.conf
RUN echo 'PassengerDefaultRuby /usr/local/bin/ruby' >> /etc/apache2/mods-available/passenger.conf
RUN a2enmod passenger
RUN service apache2 restart
 # A supp juste une vérification
RUN apache2ctl -t -D DUMP_MODULES

ADD 001-snorby.conf /etc/apache2/sites-available/
RUN cd /etc/apache2/sites-available/ && a2ensite 001-snorby.conf && service apache2 restart

RUN cd /etc/apache2/sites-enabled/ && a2dissite 000-default.conf && service apache2 restart

ADD barnyard2.conf /etc/snort
RUN chmod o-r /etc/snort/barnyard2.conf

EXPOSE 3000
