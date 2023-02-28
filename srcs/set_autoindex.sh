#!/bin/bash
if [ $AUTOINDEX = "ON" ]
then
	sed -i 's/autoindex off;/autoindex on;/' etc/nginx/sites-available/ft_server.conf
else
	sed -i 's/autoindex on;/autoindex off;/' etc/nginx/sites-available/ft_server.conf
fi

nginx -s reload
