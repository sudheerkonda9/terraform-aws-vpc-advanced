resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block # its user wish to provide , let ask user to provide cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.vpc_tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.igw_tags

  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  map_public_ip_on_launch = true #we are asking to provide public IP address ,so if you provision any EC2 instance in this subnet bydefault you will get public IP but in private and database subnets you will not get public IP 

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-${local.azs[count.index]}"
      #o/p : roboshop-public-us-east-1a , roboshop-public-us-east-1b
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-${local.azs[count.index]}"
      #o/p : roboshop-public-us-east-1a , roboshop-public-us-east-1b
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database-${local.azs[count.index]}"
      #o/p : roboshop-public-us-east-1a , roboshop-public-us-east-1b
    }
  )
}

# Public Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.main.id
  # }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public"
    },
    var.public_route_table_tags
  )

}

#Always Add route seperately
resource "aws_route" "public" {

  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0" 
  #its not vpc peering connection. it is Gate way ID
  gateway_id = aws_internet_gateway.main.id

}

resource "aws_eip" "eip" {

  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id          # we need elastic IP here 
  subnet_id     = aws_subnet.public[0].id # Im Provisioning NAT in public subnet us-east-1a

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# PPrivate Route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"             # Here the route is internet , but is should be through the NAT gateway ID instead of IGW(internet gateway)
  #   nat_gateway_id = aws_nat_gateway.main.id # NAT gate way
  #   #so in public route table you are connecting to internet by IGW but in private route table you r connecting to internet through NAT gate way 
  # }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private"
    },
    var.private_route_table_tags
  )

}

#Always Add route seperately
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0" 
  #its not vpc peering connection. it is Gate way ID
  nat_gateway_id = aws_nat_gateway.main.id

}


# database Route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"             # Here the route is internet , but is should be through the NAT gateway ID instead of IGW(internet gateway)
  #   nat_gateway_id = aws_nat_gateway.main.id # NAT gate way
  #   #so in public route table you are connecting to internet by IGW but in private route table you r connecting to internet through NAT gate way 
  # }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database"
    },
    var.database_route_table_tags
  )

}

#Always Add route seperately
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0" 
  #its not vpc peering connection. it is Gate way ID
  nat_gateway_id = aws_nat_gateway.main.id

}

#Associations:
#Associate public Route table with public Subnets(roboshop-public-1a &  roboshop-public-1b)
# aws_route_table.public -----> roboshop-public-1a
# aws_route_table.public -----> roboshop-public-1b
resource "aws_route_table_association" "public" {

  count          = length(var.public_subnet_cidr) # output =2 .It is iterating 2 times
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

#Private subnets Association:
resource "aws_route_table_association" "private" {

  count          = length(var.private_subnet_cidr) # output =2 .It is iterating 2 times
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

#Database subnets Association:
resource "aws_route_table_association" "database" {

  count          = length(var.database_subnet_cidr) # output =2 .It is iterating 2 times
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

resource "aws_db_subnet_group" "roboshop" {
  name       = var.project_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.db_subnet_group_tags
  )
}


