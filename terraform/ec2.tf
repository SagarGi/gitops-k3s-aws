# 1. Query latest Ubuntu 22.04 LTS AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. SSH Key Pair (Imports your local public key)
resource "aws_key_pair" "k3s_key" {
  key_name   = "${var.environment}-k3s-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

# 3. EC2 Instance Provisioner
resource "aws_instance" "k3s_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s_node.id]
  key_name               = aws_key_pair.k3s_key.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.environment}-k3s-server"
  }
}

# 4. Elastic IP Allocation
resource "aws_eip" "k3s_eip" {
  instance = aws_instance.k3s_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.environment}-k3s-eip"
  }
}