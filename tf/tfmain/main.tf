provider "aws" {
  profile = "omopfhir"
  region = "us-east-2"
}

data "aws_secretsmanager_secret_version" "omopfhir" {
  secret_id = "omopfhir/db_creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.omopfhir.secret_string
  )
}

data "aws_availability_zones" "availability_zones" {}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_vpc" "omopfhir" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "omopfhir"
  }
}

resource "aws_subnet" "omopfhir_public" {
  vpc_id                  = aws_vpc.omopfhir.id
  cidr_block              = element(var.subnet_one_cidr, 0)
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "omopfhir_public"
  }
}

#resource "aws_subnet" "omopfhir_public_two" {
#  vpc_id                  = aws_vpc.omopfhir.id
#  cidr_block              = element(var.subnet_one_cidr, 1)
#  availability_zone       = data.aws_availability_zones.availability_zones.names[1]
#  map_public_ip_on_launch = true
#  tags = {
#    Name = "omopfhir_public_two"
#  }
#}

resource "aws_subnet" "omopfhir_private" {
  vpc_id                  = aws_vpc.omopfhir.id
  cidr_block              = element(var.subnet_two_cidr, 0)
  availability_zone       = data.aws_availability_zones.availability_zones.names[0]
  tags = {
    Name = "omopfhir_private"
  }
}

resource "aws_subnet" "omopfhir_private_two" {
  vpc_id                  = aws_vpc.omopfhir.id
  cidr_block              = element(var.subnet_two_cidr, 1)
  availability_zone       = data.aws_availability_zones.availability_zones.names[1]
  tags = {
    Name = "omopfhir_private_two"
  }
}

## create internet gateway
resource "aws_internet_gateway" "omopfhir" {
  vpc_id = aws_vpc.omopfhir.id
  tags = {
    Name = "omopfhir"
  }
}

## create public route table (associated with internet gateway)
resource "aws_route_table" "omopfhir_public" {
  vpc_id = aws_vpc.omopfhir.id
  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.omopfhir.id
  }
  tags = {
    Name = "omopfhir_public"
  }
}

## create private subnet route table
resource "aws_route_table" "omopfhir_private" {
  vpc_id = aws_vpc.omopfhir.id
  tags = {
    Name = "omopfhir_private"
  }
}

## create default route table
resource "aws_default_route_table" "omopfhir" {
  default_route_table_id = aws_vpc.omopfhir.default_route_table_id
  tags = {
    Name = "omopfhir"
  }
}

## associate public subnets with public route table
resource "aws_route_table_association" "omopfhir_public" {
  subnet_id      = aws_subnet.omopfhir_public.id
  route_table_id = aws_route_table.omopfhir_public.id
}

#resource "aws_route_table_association" "omopfhir_public_two" {
#  subnet_id      = aws_subnet.omopfhir_public_two.id
#  route_table_id = aws_route_table.omopfhir_public.id
#}

## associate private subnets with private route table
resource "aws_route_table_association" "omopfhir_private" {
  subnet_id      = aws_subnet.omopfhir_private.id
  route_table_id = aws_route_table.omopfhir_private.id
}

resource "aws_route_table_association" "omopfhir_private_two" {
  subnet_id      = aws_subnet.omopfhir_private_two.id
  route_table_id = aws_route_table.omopfhir_private.id
}

## create security group for web
resource "aws_security_group" "omopfhir_web" {
  name        = "omopfhir"
  description = "Allow inbound web and ssh"
  vpc_id      = aws_vpc.omopfhir.id
  tags = {
    Name = "omopfhir"
  }
}

# create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
  count             = length(var.web_ports)
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = element(var.web_ports, count.index)
  to_port           = element(var.web_ports, count.index)
  security_group_id = aws_security_group.omopfhir_web.id

}
# create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
  count             = length(var.web_ports)
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = element(var.web_ports, count.index)
  to_port           = element(var.web_ports, count.index)
  security_group_id = aws_security_group.omopfhir_web.id
}

## create security group for db
resource "aws_security_group" "omopfhir_db" {
  name        = "db_security_group"
  description = "Allow inbound postgres and ssh"
  vpc_id      = aws_vpc.omopfhir.id
  tags = {
    Name = "omopfhir_db"
  }
}
## create security group ingress rule for db
resource "aws_security_group_rule" "db_ingress" {
  count             = length(var.db_ports)
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = element(var.db_ports, count.index)
  to_port           = element(var.db_ports, count.index)
  security_group_id = aws_security_group.omopfhir_db.id
}
## create security group egress rule for db
resource "aws_security_group_rule" "db_egress" {
  count             = length(var.db_ports)
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = element(var.db_ports, count.index)
  to_port           = element(var.db_ports, count.index)
  security_group_id = aws_security_group.omopfhir_db.id
}

resource "aws_key_pair" "omopfhir" {
  key_name   = "omopfhir"
  public_key = file("~/.ssh/terraform.pub")
}

## create aws rds subnet groups
resource "aws_db_subnet_group" "omopfhir" {
  name       = "omopfhir_dbsg"
  subnet_ids = [aws_subnet.omopfhir_private.id,
                aws_subnet.omopfhir_private_two.id]
  tags = {
    Name = "omopfhir"
  }
}

resource "aws_db_instance" "omopfhirdb" {
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "12.5"
  instance_class        = "db.t3.medium"
  allocated_storage     = 25
  max_allocated_storage = 60
  storage_encrypted     = false
  name                  = "omop"
  username              = local.db_creds.username
  password              = local.db_creds.password
  port                  = "5432"
  publicly_accessible   = false
  skip_final_snapshot   = true
  vpc_security_group_ids = [aws_security_group.omopfhir_db.id]
  db_subnet_group_name   = aws_db_subnet_group.omopfhir.name
  # disable backups to create DB faster
  backup_retention_period = 0
  tags =  {
    Name = "omopfhir"
  }
}

resource "aws_instance" "omopfhir" {
  key_name               = aws_key_pair.omopfhir.key_name
#  ami                    = data.aws_ami.amazon-linux-2.id
  ami                    = "ami-01aab85a5e4a5a0fe"
  instance_type          = "t3.large"
  vpc_security_group_ids = [aws_security_group.omopfhir_web.id]
  subnet_id              = aws_subnet.omopfhir_public.id

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "omopfhir"
  }

  volume_tags = {
    Name = "omopfhir"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host        = self.public_ip
  }

  depends_on = [aws_db_instance.omopfhirdb]
}

resource "aws_eip" "omopfhir" {
  vpc      = true
  instance = aws_instance.omopfhir.id
}

