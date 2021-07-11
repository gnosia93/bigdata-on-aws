resource "aws_vpc" "bigdata" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags = {
        Name = "bigdata"
    } 
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.bigdata.id   

    tags = {
        Name = "bigdata"
    } 
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" bigdata_pub1 {
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_pub1

    tags = {
        Name = "bigdata_pub1"
    } 
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
