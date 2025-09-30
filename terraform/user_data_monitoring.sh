#!/bin/bash
# install docker
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# create directory and pull monitoring compose files from user data (we'll embed them via terraform file)
mkdir -p /home/ec2-user/monitoring
cat > /home/ec2-user/monitoring/docker-compose.yml <<'EOF'
# will be replaced with actual compose content by Terraform file() when writing user_data if desired
EOF

chown -R ec2-user:ec2-user /home/ec2-user/monitoring
cd /home/ec2-user/monitoring
sudo -u ec2-user /usr/local/bin/docker-compose up -d
# end of script