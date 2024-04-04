# Load Balanced VMs in AWS

A demo of load balanced VMs with autoscaling deployed in AWS via Terraform.

The load balancer listens on port 443 and has an SSL cert for kaplans.com.

The VMs are deployed in a private subnet and listen on port 8192.

Turnup instructions:
1. git clone https://github.com/scottkaplan/aws_vm_cluster.git
1. cd aws_vm_cluster/terraform
1. terraform init
1. terraform apply
1. Visit https://demo.kaplans.com

Current status:
1. The worker VMs are coming up with an http server on port 80.
1. The workers are passing health check
1. The LB is not responding on port 443
