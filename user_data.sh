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
  -dp 5000:5000 my-image-app-image
