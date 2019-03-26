#!/usr/bin/env bash
set -e

# wait for db
WAIT=0; echo "Waiting for ${DB_HOST} to start"
while ! nc -z ${DB_HOST} ${DB_PORT}; do [ "$WAIT" -gt 60 ] && echo "Error: DB timeout" && exit 1 || sleep 1 && WAIT=$(($WAIT + 1)); done
echo "DB is up"

if [[ "$1" == httpd* ]]; then

        # Enable commonly used apache modules
        sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf
        sed -i '/LoadModule deflate_module/s/^#//g' /etc/apache2/httpd.conf
        sed -i '/LoadModule expires_module/s/^#//g' /etc/apache2/httpd.conf

        sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/microweber\"#g" /etc/apache2/httpd.conf
        sed -i "s#/var/www/localhost/htdocs#/var/www/microweber#" /etc/apache2/httpd.conf
        printf "\n<Directory \"/var/www/microweber\">\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n" >> /etc/apache2/httpd.conf

        cp /var/www/microweber-defaults/.htaccess /var/www/microweber
        cat /var/www/microweber-defaults/htaccess_secured >> /var/www/microweber/.htaccess
        chown -R apache:apache /var/www/microweber/.htaccess

        if [ `ls -A /var/www/microweber/config | wc -m` == "0" ]; then
            cp -r /var/www/microweber-defaults/config /var/www/microweber
            chown -R apache:apache /var/www/microweber/config
        fi

        if [ `ls -A /var/www/microweber/userfiles | wc -m` == "0" ]; then
            cp -r /var/www/microweber-defaults/userfiles /var/www/microweber
            chown -R apache:apache /var/www/microweber/userfiles
        fi

        if [ -f "/var/www/microweber/config/microweber.php" ]; then
                echo "CMS is installed, skipping"
        else
                sudo --preserve-env -u apache php /var/www/microweber/artisan microweber:install \
                    ${MW_EMAIL} ${MW_USER} ${MW_PASSWORD} \
                    ${DB_HOST} ${DB_NAME} ${DB_USER} ${DB_PASS} ${DB_DRIVER} ${DB_PREFIX}

                chown -R apache:apache /var/www/microweber/storage
        fi
fi


exec "$@"
