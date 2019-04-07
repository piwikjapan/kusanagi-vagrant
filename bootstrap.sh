#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e
# errors if an variable is referenced before being set
set -u

KUSANAGI_PATH="/usr/local/src/kusanagi"
echo "KUSANAGI_PATH ${KUSANAGI_PATH}"
cp "${KUSANAGI_PATH}"/prime-strategy.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/zabbix.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/remi.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/remi-safe.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/remi-php70.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/remi-php71.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/MariaDB.repo /etc/yum.repos.d/
cp "${KUSANAGI_PATH}"/RPM-GPG-KEY-ZABBIX /etc/pki/rpm-gpg/
cp "${KUSANAGI_PATH}"/RPM-GPG-KEY-remi /etc/pki/rpm-gpg/
cp "${KUSANAGI_PATH}"/my.cnf /root/.my.cnf
cp "${KUSANAGI_PATH}"/mysql-clients.cnf "${KUSANAGI_PATH}"/server.cnf /etc/my.cnf.d/
cp "${KUSANAGI_PATH}"/kusanagi.conf /etc/
mkdir -p /etc/httpd/conf.d/
cp "${KUSANAGI_PATH}"/_ssl.conf /etc/httpd/conf.d/
mkdir -p /usr/share/httpd/icons
cp "${KUSANAGI_PATH}"/php.gif /usr/share/httpd/icons/
yum clean all
yum -y update
yum -y install libjpeg-turbo-devel epel-release mlocate expect git vsftpd lftp
# for kusanagi-mozjpeg package
ldconfig
groupadd kusanagi -f -g 1001
groupadd www -f -g 1002
groupadd postgres -f -g 26
groupadd apache -f -g 48
old_setting=${-//[^e]/}
set +e
id -u kusanagi >/dev/null 2>&1; if [ $? -ne 0 ]; then useradd -u 1001 -g 1001 kusanagi; usermod kusanagi -G www,kusanagi; chmod 775 /home/kusanagi; fi;
id -u apache >/dev/null 2>&1; if [ $? -ne 0 ]; then useradd -u 48 -g 48 -r -s /sbin/nologin -d /usr/share/httpd apache; usermod apache -G apache; fi;
# /home/httpd is used from hhvm
id -u httpd >/dev/null 2>&1; if [ $? -ne 0 ]; then useradd -m -u 1002 -g 1002 -s /bin/false httpd; fi;
id -u postgres >/dev/null 2>&1; if [ $? -ne 0 ]; then useradd -m -u 26 -g 26 -c 'PostgreSQL Server' postgres; fi;
if [[ -n "$old_setting" ]]; then set -e; else set +e; fi;
# for hhvm
mkdir -p /var/lib/php/wsdlcache
mkdir -p /var/lib/php/session
chmod -R 770 /var/lib/php
chgrp -R www /var/lib/php
touch /etc/kusanagi
# /etc/mime.types is used from kusanagi-httpd
yum -y install mailcap
yum -y install --enablerepo=epel \
  double-conversion libc-client
yum -y install --enablerepo=remi \
  fastlz gd-last libzip5
yum -y install \
  kusanagi-nginx kusanagi-libbrotli kusanagi-openssl kusanagi kusanagi-php7 kusanagi-wp-cli \
  kusanagi-httpd kusanagi-hhvm kusanagi-nghttp2 kusanagi-wp
mkdir -p /var/lib/mysql
yum -y install --enablerepo=mariadb \
  MariaDB-common MariaDB-shared MariaDB-devel MariaDB-Galera-server MariaDB-client
mkdir -p /var/log/mysql
chmod -R 775 /var/log/mysql
chown -R mysql:mysql /var/log/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 711 /var/lib/mysql
yum -y install --enablerepo=remi-php56 \
  php-pecl-jsonc-devel php-gd php-xmlrpc php-mbstring php-cli php-devel php-pecl-apcu php-mcrypt php-pecl-zip php-common php-xml
#rpm -qa | sed -n 's/kusanagi-\([0-9]\+\.[0-9]\+\.[0-9]\+[-0-9]*\).*/KUSANAGI Version \1\nvagrant/p' > /etc/kusanagi
cp -f "${KUSANAGI_PATH}"/motd /etc/motd
rpm -qa | sed -n 's/kusanagi-\([0-9]\+\.[0-9]\+\.[0-9]\+[-0-9]*\).*/    Version \1, Powered by Prime Strategy.\n/p' >> /etc/motd
systemctl daemon-reload
old_setting=${-//[^e]/}
set +e
systemctl is-enabled mariadb 2>&1 | grep "No such file or directory" >/dev/null; if [ $? -eq 0 ]; then DB_SERVICE="mysql"; else DB_SERVICE="mariadb"; fi
if [[ -n "$old_setting" ]]; then set -e; else set +e; fi;
systemctl enable $DB_SERVICE.service
systemctl start $DB_SERVICE.service
systemctl enable vsftpd.service
systemctl start vsftpd.service
chmod 775 "${KUSANAGI_PATH}/mysql_secure_installation_expect"
${KUSANAGI_PATH}/mysql_secure_installation_expect
updatedb
DBPASS=$(cat /root/.my.cnf | sed -n -e '/password.*=/p'| grep -o '[^ =]\+$' | sed -e 's/\"//g')
echo "------------------------------------------------------------------------"
echo "Initial database password is \"$DBPASS\"".
echo "Provisioning is over. Power off. Execute \"vagrant up\" command again."
echo "------------------------------------------------------------------------"
poweroff