resource "aws_vpc" "first_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}

resource "aws_subnet" "first_subnet" {
  vpc_id                  = aws_vpc.first_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "Dev-public"
  }
}

resource "aws_internet_gateway" "first_net_gateway" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "Dev-igw"
  }
}

resource "aws_route_table" "first_public_rt" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "Dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.first_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.first_net_gateway.id

}

resource "aws_route_table_association" "first_rt_association" {
  subnet_id      = aws_subnet.first_subnet.id
  route_table_id = aws_route_table.first_public_rt.id
}

resource "aws_security_group" "first_sg" {
  name        = "Dev_sg"
  description = "Dev security group"
  vpc_id      = aws_vpc.first_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.123.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "first_key" {
  key_name   = "first-key"
  public_key = file("~/.ssh/firstkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.first_ami.id
  key_name               = aws_key_pair.first_key.id
  vpc_security_group_ids = [aws_security_group.first_sg.id]
  subnet_id              = aws_subnet.first_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Dev-node"
  }

  
}