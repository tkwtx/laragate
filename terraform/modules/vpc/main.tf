locals {
  subnet_cidr_block_public = lookup(var.subnet_cidr_block, "public")
  subnet_cidr_block_private = lookup(var.subnet_cidr_block, "private")
  sg_conf_alb = lookup(var.sg_conf, "alb")
  sg_conf_private_link = lookup(var.sg_conf, "private_link")
  end_points = {
    api = "com.amazonaws.${var.region}.ecr.api"
    dkr = "com.amazonaws.${var.region}.ecr.dkr"
    logs = "com.amazonaws.${var.region}.logs"
    ssm = "com.amazonaws.${var.region}.ssm"
    ssmmessages = "com.amazonaws.${var.region}.ssmmessages"
  }
}

/* VPC */
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.app_name
  }
}

/* SUBNET */
resource "aws_subnet" "public_subnet" {
  for_each = local.subnet_cidr_block_public

  vpc_id = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = "public-${var.app_name}-${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = local.subnet_cidr_block_private

  vpc_id = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = "private-${var.app_name}-${each.key}"
  }
}

/* INTERNET GATEWAY */
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

/* ROUTE TABLE */
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public"
  }
}

resource "aws_route_table" "private_link" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.app_name}-private-link"
  }
}

/* ROUTE TABLE ASSOCIATION */
resource "aws_route_table_association" "igw_to_public_subnet" {
  for_each = {for k, v in aws_subnet.public_subnet: k => v.id}

  route_table_id = aws_route_table.main.id
  subnet_id = each.value
}

resource "aws_route_table_association" "private_link_to_private_subnet" {
  for_each = {for k, v in aws_subnet.private_subnet: k => v.id}

  route_table_id = aws_route_table.private_link.id
  subnet_id = each.value
}

/* SECURITY GROUP */
resource "aws_security_group" "alb" {
  name = "alb"
  description = lookup(local.sg_conf_alb, "description")
  vpc_id = aws_vpc.main.id

  dynamic ingress {
    for_each = lookup(lookup(local.sg_conf_alb, "ingress"), "port")

    content {
      from_port = ingress.value
      protocol = lookup(lookup(local.sg_conf_alb, "ingress"), "protocol")
      to_port = ingress.value
      cidr_blocks = lookup(lookup(local.sg_conf_alb, "ingress"), "cidr_block")
    }
  }

  egress {
    from_port = lookup(lookup(local.sg_conf_alb, "egress"), "port")
    protocol = lookup(lookup(local.sg_conf_alb, "egress"), "protocol")
    to_port = lookup(lookup(local.sg_conf_alb, "egress"), "port")
    cidr_blocks = lookup(lookup(local.sg_conf_alb, "egress"), "cidr_block")
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_security_group" "private_link" {
  name = "private-link"
  description = lookup(local.sg_conf_private_link, "description")
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = lookup(lookup(local.sg_conf_private_link, "ingress"), "port")
    protocol = lookup(lookup(local.sg_conf_private_link, "ingress"), "protocol")
    to_port = lookup(lookup(local.sg_conf_private_link, "ingress"), "port")
    cidr_blocks = lookup(lookup(local.sg_conf_private_link, "ingress"), "cidr_block")
  }

  egress {
    from_port = lookup(lookup(local.sg_conf_private_link, "egress"), "port")
    protocol = lookup(lookup(local.sg_conf_private_link, "egress"), "protocol")
    to_port = lookup(lookup(local.sg_conf_private_link, "egress"), "port")
    cidr_blocks = lookup(lookup(local.sg_conf_private_link, "egress"), "cidr_block")
  }

  tags = {
    Name = "${var.app_name}-private-link"
  }
}

/* ENDPOINT */
resource "aws_vpc_endpoint" "private_link" {
  for_each = local.end_points

  service_name = each.value
  vpc_id = aws_vpc.main.id
  subnet_ids = [for v in aws_subnet.private_subnet: v.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_link.id]

  tags = {
    Name = "${var.app_name}-${each.key}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_link.id]

  tags = {
    Name = "${var.app_name}-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id = aws_route_table.private_link.id
}
