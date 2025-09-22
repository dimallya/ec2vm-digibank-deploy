provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type

  # Cloud-init / user data script that runs on boot
  user_data = <<-EOF
              #!/bin/bash
              set -xe

              # Update packages
              yum update -y

              # Install docker (Amazon Linux extras) and git
              amazon-linux-extras install -y docker
              yum install -y git

              # Start docker and allow ec2-user to use it
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user

              # Install docker-compose (v1 binary). If you prefer v2, swap in plugin installation.
              DOCKER_COMPOSE_PATH=/usr/local/bin/docker-compose
              if [ ! -f "$DOCKER_COMPOSE_PATH" ]; then
                curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o $DOCKER_COMPOSE_PATH
                chmod +x $DOCKER_COMPOSE_PATH
              fi

              # Switch to ec2-user home, clone repo if not present (or pull)
              cd /home/ec2-user
              REPO_DIR="digitalbank-gen-one"
              if [ -d "$REPO_DIR" ]; then
                cd $REPO_DIR
                git pull || true
              else
                git clone https://github.com/digisic/digitalbank-gen-one.git
                cd $REPO_DIR
              fi
              cd deploy/docker-compose/
              docker-compose -f docker-compose-h2.yml up

              EOF

  tags = {
    VmName = var.instance_name
  }
  
}


