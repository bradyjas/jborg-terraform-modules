#### Outputs ####

output "vpc_id" {
  description = "ID of the VPC created"
  value       = "${aws_vpc.this.id}"
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = ["${aws_subnet.public.*.id}"]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = ["${aws_subnet.private.*.id}"]
}