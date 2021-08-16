!/usr/bin/env bash
sudo yum update -y
sudo amazon-linux-extras install -y docker
#sudo yum install docker 
sudo service docker start
sudo usermod -a -G docker ec2-user
