variable "aws_region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_key_name" { description = "Name of an existing EC2 keypair to access monitoring instance" }
variable "monitoring_instance_type" { default = "t3.small" }
variable "domain_name" { description = "domain used for Grafana (e.g. grafana.example.com)" }
variable "admin_email" { description = "email for certbot registration" }
