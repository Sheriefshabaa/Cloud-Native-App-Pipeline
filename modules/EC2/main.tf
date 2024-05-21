# AMI Source
data "aws_ami" "aws_image_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"]
  }
}

# Key Pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUy4WplYzcfPTQWTcQ7+nBR3lJGsPYyCrEAMxPXQcquv3+nEUROCTj7/GJ2npkGKXtkOoW9BrVtv/bPCTg/oJTUdFsk0B9bYqSIPmikKJfOL4IcmrZlonReHM7yRd0elkbK42DaBBGeFkXaN8aJeUIB/2mfKkHNrzueUD54ozCwkgiUoBOxsawgH5mCSu5WZen7p38ZPlBaNsKP6W2efAII/FW8KpbAkvEHMPeWkYS+B0NcMUiFw4EyLS8GoOK3xsai7FkQkRMWPzuMcE7UeBVEueqD0plD4D3p1cIC38CSOz58PPomfQANzCRvpMRcSZIvUgf0U9wTe8duQmXoOgt spero-spatis@SperoSpatis"
}

# Private Instances Resource
resource "aws_instance" "private" {
  count = var.ec2_config["count"][1]

  ami = data.aws_ami.aws_image_latest.id
  instance_type = var.ec2_config["type"][count.index + 2]
  subnet_id = var.private_subnet_ids[count.index]
  security_groups = [ var.private_instance_sg_id ]
  key_name = aws_key_pair.my_key_pair.key_name

  # user_data = var.apache_script
    user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
systemctl restart apache2
EOF

  tags = {
    Name = "${var.name}-${var.ec2_config["name"][count.index + 2]}-${count.index}"
  }
}

# Public Instances Resource
resource "aws_instance" "public" {
  count = var.ec2_config["count"][0]

  ami = data.aws_ami.aws_image_latest.id
  instance_type = var.ec2_config["type"][count.index]
  subnet_id = var.public_subnet_ids[count.index]
  security_groups = [ var.public_instance_sg_id ]
  key_name = aws_key_pair.my_key_pair.key_name
  
  associate_public_ip_address = true

  # user_data = var.proxy_script

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo cat > /etc/nginx/sites-enabled/default << EOL
server {
    listen 80 default_server;
    location / {
      proxy_pass http://${var.privte_lb_dns};
    }
}
  
EOL
sudo systemctl restart nginx

EOF

  tags = {
    Name = "${var.name}-${var.ec2_config["name"][count.index]}-${count.index}"
  }
}
