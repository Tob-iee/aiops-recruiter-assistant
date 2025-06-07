
# Get availability zones
data "aws_availability_zones" "available" {}

# Create a VPC
resource "aws_vpc" "ecs_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

  tags = {
    Name = "ecs-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "ecs_public" {
  count                   = 2
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = element(["10.0.4.0/24", "10.0.5.0/24"], count.index)
  availability_zone       = element(["af-south-1a", "af-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index}"
  }
}

# Create private subnets
resource "aws_subnet" "ecs_private" {
  count             = 2
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone = element(["af-south-1a", "af-south-1b"], count.index)

  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "ecs_public" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

# Associate public subnets with route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.ecs_public[count.index].id
  route_table_id = aws_route_table.ecs_public.id
}

# NAT Gateway
resource "aws_eip" "ecs_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ecs_nat" {
  allocation_id = aws_eip.ecs_nat.id
  subnet_id     = aws_subnet.ecs_public[0].id

  tags = {
    Name = "${var.cluster_name}-nat"
  }

  depends_on = [aws_internet_gateway.ecs_igw]
  
}

# Private Route Tables and Associations
resource "aws_route_table" "ecs_private" {
  count  = 2
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecs_nat.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "ecs_private" {
  count          = 2
  subnet_id      = aws_subnet.ecs_private[count.index].id
  route_table_id = aws_route_table.ecs_private[count.index].id
}


# resource "aws_subnet" "ecs_az3" {
#     vpc_id = "${aws_vpc.ecs-vpc.id}"
#     # cidr_block = var.private_subnets
#     cidr_block = "10.0.3.0/24"
#     availability_zone = "ap-south-1c"
#     tags = {
#         Name = "ecs-subnet-az3"
        
#     }
# }
