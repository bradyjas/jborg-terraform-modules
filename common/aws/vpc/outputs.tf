#### Outputs ####

output "vpc_id" {
  description = "ID of the VPC created"
  value       = "${aws_vpc.this.id}"
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = ["${aws_subnet.public.*.id}"]
}

output "public_subnet_cidr_blocks" {
  description = "List of public CIDR blocks"
  value       = ["${aws_subnet.public.*.cidr_block}"]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = ["${aws_subnet.private.*.id}"]
}

output "private_subnet_cidr_blocks" {
  description = "List of private CIDR blocks"
  value       = ["${aws_subnet.private.*.cidr_block}"]
}
