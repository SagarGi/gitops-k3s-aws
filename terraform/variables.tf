variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "Your local public IP address in CIDR format (e.g., 203.0.113.25/32)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.my_ip))
    error_message = "The my_ip variable must be a valid CIDR string (e.g., x.x.x.x/32)."
  }
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}