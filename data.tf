
#Our module developer is querrying the AWS and then he is asking the availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

#how he gets the region? Region is always provided by the user in"provider.tf" (us-east-1) file , so according to this region our module developer will pull the availability zones .Above data is availability zone

# locals {
#   azs = slice(data.aws_availability_zones.available.names,0,2)
# }

# output "azs" {
#   value = local.azs
# }
