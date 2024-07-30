#!/bin/bash

apt-get update -y
apt install curl gpg gnupg2 software-properties-common ca-certificates apt-transport-https lsb-release unzip git -y
add-apt-repository ppa:ondrej/php -y
apt -y install apache2 php8.3 php8.3-xml php8.3-intl php8.3-mbstring php8.3-sqlite3 php8.3-zip php8.3-fpm
a2enmod proxy_fcgi setenvif
a2enconf php8.3-fpm
systemctl restart apache2
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
ln -s /root/composer.phar /usr/local/bin/composer
export COMPOSER_ALLOW_SUPERUSER=1
echo "export COMPOSER_ALLOW_SUPERUSER=1" >> /root/.bashrc
curl -sS https://get.symfony.com/cli/installer | bash
ln -s /root/.symfony5/bin/symfony /usr/local/bin/symfony
symfony check:requirements
git config --global user.email "hello@demo.com"
git config --global user.name hello
composer require -n symfony/flex
composer config --no-plugins allow-plugins.symfony/flex true
composer require -n symfony/flex
mkdir -p /var/www && cd /var/www
symfony new --demo my_project
chown -R www-data:www-data /var/www/my_project
cat<<EOF>/etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    <FilesMatch \.php\$>
        SetHandler proxy:unix:/run/php/php8.3-fpm.sock|fcgi://dummy
    </FilesMatch>
    DocumentRoot /var/www/my_project/public
    <Directory /var/www/my_project/public>
        AllowOverride None
        Require all granted
        FallbackResource /index.php
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
systemctl restart apache2
