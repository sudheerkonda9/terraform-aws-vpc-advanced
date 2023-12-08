###VPC peering with default VPC
resource "aws_vpc_peering_connection" "peering" {
  #We are going to create peering connection when ever user wants otherwise no need of peering connection
  count = var.is_peering_required ? 1 : 0
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id = aws_vpc.main.id
  #requestor , default VPC is our requestor
  vpc_id      = var.requestor_vpc_id
  auto_accept = true
  tags = merge(
    {
      Name = "VPC Peering between default VPC and ${var.project_name}"
    },
  var.common_tags
  )
}

#Add route in default routtable to connect with public route table
resource "aws_route" "default_route" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.cidr_block #Roboshop VPC cidr destination
  #since we set count parameter, it is treated as a list, even single element you should write list synatx
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  #depends_on                = [aws_route_table.testing]
}

#Simillarly , Add route in roboshop public route table to connect with default route table
resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.default_vpc_cidr #Default VPC cidr destination
  #since we set count parameter, it is treated as a list, even single element you should write list synatx
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  #depends_on                = [aws_route_table.testing]
}

#Private peering
resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.default_vpc_cidr #Default VPC cidr destination
  #since we set count parameter, it is treated as a list, even single element you should write list synatx
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  #depends_on                = [aws_route_table.testing]
}

#database peering
resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = var.default_vpc_cidr #Default VPC cidr destination
  #since we set count parameter, it is treated as a list, even single element you should write list synatx
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  #depends_on                = [aws_route_table.testing]
}