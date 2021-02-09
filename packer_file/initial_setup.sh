#!/bin/bash

sudo yum -y update
sudo yum -y install htop
sudo amazon-linux-extras install docker
sudo service docker start
