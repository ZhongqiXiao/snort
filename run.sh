#!/bin/sh
# run mysql et apache2
service mysql start
service apache2 start

# run snort
/usr/local/bin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i eth0 &

# run barnyard2
#/usr/local/bin/barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -q -w /var/log/snort/barnyard2.waldo -g snort -u snort -D -a /var/log/snort/archived_logs &

# run snorby
cd /var/www/html/snorby/ && bundle exec rails server -e production

