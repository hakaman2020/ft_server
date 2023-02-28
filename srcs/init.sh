#!/bin/bash

# starting the servers
service mysql start
service php7.3-fpm start

# set the autoindex to the desired value (default = ON)
if [ $AUTOINDEX = "ON" ]
then
	sed -i 's/autoindex off;/autoindex on;/' etc/nginx/sites-available/ft_server.conf
elif [ $AUTOINDEX = "OFF" ]
then
	sed -i 's/autoindex on;/autoindex off;/' etc/nginx/sites-available/ft_server.conf
fi

# make nginx a foreground process to prevent the container to exit because there
# is no foreground process active
nginx -g 'daemon off;'

