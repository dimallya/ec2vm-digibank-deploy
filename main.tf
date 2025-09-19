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

  tags = {
    VmName = var.instance_name
  }
}

resource "null_resource" "run_script" {
  depends_on = [aws_instance.ubuntu] # Ensure EC2 is created first

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ssh_private_key
    host        = aws_instance.ubuntu.public_ip # IP address of the remote server
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user",
      "git clone https://github.com/digisic/digitalbank-gen-one.git",
      "cd digitalbank-gen-one/deploy/docker-compose",
      "docker-compose -f docker-compose-h2.yml up"
    ]
  }
}
