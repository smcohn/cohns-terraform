#! /bin/bash
sudo echo "${db_server_endpoint}" >> /var/www/rpm/bgprod/lib/db_server_endpoint
sudo echo "${cloudfront_endpoint}" >> /var/www/rpm/bgprod/lib/cloudfront_endpoint
sudo /sbin/service httpd start
