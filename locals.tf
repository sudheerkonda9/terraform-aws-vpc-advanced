
#We are fetching dynamically the first two availabilty zones from AWS using data source and then i am storing it ina variable called locals.azs
locals {
  azs = slice(data.aws_availability_zones.available.names,0,2)
}

