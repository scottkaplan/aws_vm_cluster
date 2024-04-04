# aws_vm_cluster

A demo of load balanced VMs with autoscaling deployed in AWS via Terraform.

The load balancer listens on port 443 and has an SSL cert for kaplans.com.

The VMs are deployed in a private subnet and listen on port 8192.

Current status:
1. The worker VMs are coming up with an http server on port 80.
2. The workers are passing health check
3. The LB is not responding on port 443
