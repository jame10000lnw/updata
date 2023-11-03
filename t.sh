#!/bin/bash

# Go to root
cd

# Update system and install required packages
apt-get update
apt-get -y upgrade
apt-get -y install pritunl mongodb-server squid ufw nginx php-fpm vnstat

# Start Pritunl and MongoDB
systemctl start pritunl mongod
systemctl enable pritunl mongod

# Configure Squid Proxy
cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/northvar/pritunl/master/conf/squid.conf"
MYIP=$(curl -4 ifconfig.co)
sed -i "s/xxxxxxxxx/$MYIP/g" /etc/squid/squid.conf
systemctl restart squid

# Enable Firewall
ufw allow 22,80,81,222,443,8080,9700,60000/tcp
ufw allow 22,80,81,222,443,8080,9700,60000/udp
yes | ufw enable

# Change to Time GMT+7
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

# Configure Nginx
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/northvar/pritunl/master/conf/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by NorthVPN </pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/northvar/pritunl/master/conf/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/7.4/fpm/pool.d/www.conf
systemctl restart php7.4-fpm nginx

# Configure Vnstat
vnstat -u -i eth0
chown -R vnstat:vnstat /var/lib/vnstat
systemctl restart vnstat

# Install Vnstat GUI
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# Install Nano for text editing
apt-get -y install nano

# About
clear
echo "Script By North ^_^"
echo "Pritunl, MongoDB, Vnstat, Web Server, Squid Proxy Port 8080, 8000, 80"
echo "BY North"
echo "TimeZone   :  Thailand"
echo "Vnstat     :  http://$MYIP:81/vnstat"
echo "Pritunl    :  https://$MYIP"
pritunl setup-key
