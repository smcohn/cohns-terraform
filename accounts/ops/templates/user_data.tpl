#! /bin/bash
sudo yum install -y python-pip
sudo yum install -y gcc
sudo yum install -y nginx
sudo yum install -y git
sudo yum install -y java-1.8.0-openjdk
sudo yum install -y amazon-efs-utils
sudo mkdir /opt/gatling
sudo mount -t efs "${efs_filesystem}:/" /opt/gatling
sudo git clone https://github.com/alex-leonhardt/gatling-web.git /opt/gatling/gatling-web
pip install flask
pip install wtforms
pip install psutil
pip install uwsgi
sudo curl https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.3.1/gatling-charts-highcharts-bundle-3.3.1-bundle.zip --output /opt/gatling/gatling.zip
cd /opt && sudo unzip gatling.zip
sudo mv /opt/gatling/gatling-charts-highcharts-bundle-3.3.1/* /opt/gatling
cd /opt/gatling/gatling-web && sudo flask run --host 0.0.0.0 --port 80
