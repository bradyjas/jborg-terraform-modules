#### Main ####

terraform {
  required_version = ">= 0.11.8"  # Older versions not tested
}

locals {
  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : length(var.private_subnets))}"
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.tags, map("Name", format("%s-vpc", var.name)))}"
}

# DHCP Options
resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "${var.local_domain_name}"
  domain_name_servers = "${var.dns_servers}"

  tags = "${merge(var.tags, map("Name", format("%s-dopt", var.name)))}"
}

# DHCP Options Association
resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-igw", var.name)))}"
}


## Public Subnets

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, map("Name", format("%s-public-%d", var.name, count.index + 1)))}"
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-public-rtb", var.name)))}"
}

# Route Rule for Public Route Table
resource "aws_route" "public_igw" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Elastic IP for NAT Gateways
resource "aws_eip" "nat" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(var.tags, map("Name", format("%s-eip-nat-%d", var.name, count.index + 1)))}"
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(aws_eip.nat.*.id, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(var.tags, map("Name", format("%s-nat-%d", var.name, count.index + 1)))}"

  depends_on    = ["aws_internet_gateway.this"]
}


## Private Subnets

resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, map("Name", format("%s-private-%d", var.name, count.index + 1)))}"
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count = "${length(var.private_subnets) > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s-private-rtb-%d", var.name, count.index + 1)))}"
}

# Route Rule for Private Route Tables
resource "aws_route" "private_nat" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}
