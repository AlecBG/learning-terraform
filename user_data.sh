#!/bin/bash

sudo service docker start
sudo docker run\
 --env BUCKET_NAME=${bucket_name}\
 --env RDS_ENDPOINT=${rds_endpoint}\
 --env RDS_READ_REPLICA_ENDPOINT=${rds_read_replica_endpoint}\
 --env RDS_PORT=${rds_port}\
 --env RDS_USER=${rds_user}\
 --env RDS_PASSWORD=${rds_password}\
 --env RDS_DB=${rds_db}\
 --env AWS_ACCESS_KEY_ID=${aws_access_key_id}\
 --env AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}\
  -dp 5000:5000 my-image-app-image
