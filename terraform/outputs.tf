output "ec2_public_ip" {
  description = "Static Public IP address of the K3s server"
  value       = aws_eip.k3s_eip.public_ip
}

output "ecr_repository_url" {
  description = "URL of the created AWS ECR repository"
  value       = aws_ecr_repository.flask_app.repository_url
}

output "ssh_command" {
  description = "Quick command to SSH into the K3s node"
  value       = "ssh ubuntu@${aws_eip.k3s_eip.public_ip}"
}