# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    Dockerfile                                         :+:    :+:             #
#                                                      +:+                     #
#    By: hman <hman@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2021/04/26 14:10:17 by hman          #+#    #+#                  #
#    Updated: 2021/05/04 16:29:08 by hman          ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

# selecting debian os buster version
FROM debian:buster

# update the package listing and upgrade the packages 
RUN apt-get update && apt-get -y upgrade

# install wget, vim, nginx and mariadb-server (open source alternative to mysql)
RUN apt-get install -y wget vim nginx mariadb-server

# install php and the necessary plugins
RUN apt-get install -y php7.3 php7.3-mysql php7.3-fpm php-gd php-cli \
	php-mbstring php-zip php-xml php-json php-curl

# setting up database for wordpress
RUN service mysql start && \
	mysql -e "CREATE DATABASE wpdb;" && \
	mysql -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost' IDENTIFIED BY 'password' ;" && \ 
	mysql -e "FLUSH PRIVILEGES" 

# set workdirectory
WORKDIR /var/www/

# download and unpack wordpress
RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzvf latest.tar.gz && \
	rm latest.tar.gz

# copy wordpress config file with the necessary data
COPY srcs/wp-config.php ./wordpress/

# download and install wpi-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# complete the wordpress setup
RUN service mysql start && \
	wp core install --url=localhost --title=ft_server --admin_user=supervisor \
	--admin_password=wppassword --admin_email=hman@student.codam.nl \
	--skip-email --allow-root --path=/var/www/wordpress

# download and install phpmyadmin
WORKDIR /var/www/wordpress/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz && \
	tar -xzvf phpMyAdmin-5.1.0-all-languages.tar.gz && \
	mv phpMyAdmin-5.1.0-all-languages phpmyadmin && \
	rm phpMyAdmin-5.1.0-all-languages.tar.gz

# change the owner of website files to www-data and change file permissions for basic security
RUN chown -R www-data:www-data /var/www/ && \
	find /var/www/ -type d -exec chmod 755 {} \; && \
	find /var/www/ -type f -exec chmod 644 {} \;

# generate a self signed cert and private key  and store it in /ect/ssl/cert
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/certs/localhost.key \
	-out /etc/ssl/certs/localhost.crt \
	-subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/CN=hman"

# configure nginx server
COPY srcs/ft_server.conf /etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/default && \ 
	ln -s /etc/nginx/sites-available/ft_server.conf /etc/nginx/sites-enabled/ft_server

# create a directory to show that autoindex is on or off
RUN mkdir test && touch test/test.txt

# copy the initialization file and run it
WORKDIR /
ENV AUTOINDEX=ON
COPY srcs/init.sh .
COPY srcs/set_autoindex.sh .
CMD bash init.sh

