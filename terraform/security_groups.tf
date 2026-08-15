resource "aws_security_group" "k3s_node" {
  name        = "${var.environment}-k3s-node-sg"
  description = "Security group for single-node K3s platform"
  vpc_id      = aws_vpc.main.id

  # 1. SSH Access (Restricted to your IP)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # 2. K3s Kubernetes API (Restricted to your IP)
  ingress {
    description = "K3s Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # 3. HTTP Traffic (Public - Flask App / Ingress Controller)
  ingress {
    description = "HTTP Ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 4. HTTPS Traffic (Public)
  ingress {
    description = "HTTPS Ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 5. NodePort / Web UI Access (Restricted to your IP for NodePorts like Grafana/ArgoCD)
  ingress {
    description = "NodePort service access"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # 6. Egress (Allow all outbound traffic for updates and image pulls)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-k3s-node-sg"
  }
}