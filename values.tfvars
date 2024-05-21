name = "h-lab04"

region = "eu-west-1"

vpc_cidr = "10.0.0.0/16"

# private_subnet_config = {
#   count = [2]
#   CIDRs = ["10.0.0.0/24", "10.0.1.0/24"]
#   AZs = ["eu-west-1a", "eu-west-1b"]
# }

public_subnet_config = {
  count = [2]
  CIDRs = ["10.0.2.0/24", "10.0.3.0/24"]
  AZs = ["eu-west-1a", "eu-west-1b"]
}

ec2_config = {
  count = [2,2]
  type = ["t2.micro", "t2.micro", "t2.micro", "t2.micro"]
  key = ["key"]
  name = ["public-ec2", "public-ec2", "private-ec2", "private-ec2"] 
}

lb_config = {
  count = [2]
  name = ["private", "public"]
  internal = ["true", "false"]
}