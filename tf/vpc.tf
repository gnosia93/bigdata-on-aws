data "aws_availability_zones" "azlist" {
    state = "available"
}

resource "aws_vpc" "bigdata" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags = {
        Name = "bigdata"
    } 
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "bigdata_igw" {
    vpc_id = aws_vpc.bigdata.id   

    tags = {
        Name = "bigdata_igw"
    } 
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "bigdata_pub_subnet1" {
    availability_zone = data.aws_availability_zones.azlist.names[0]
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_pub1

    tags = {
        Name = "bigdata_pub_subnet1"
    } 
}

resource "aws_subnet" "bigdata_pub_subnet2" {
    availability_zone = data.aws_availability_zones.azlist.names[1]
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_pub2

    tags = {
        Name = "bigdata_pub_subnet2"
    } 
}

resource "aws_subnet" "bigdata_priv_subnet1" {
    availability_zone = data.aws_availability_zones.azlist.names[0]
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_priv1

    tags = {
        Name = "bigdata_priv_subnet1"
    } 
}

resource "aws_subnet" "bigdata_priv_subnet2" {
    availability_zone = data.aws_availability_zones.azlist.names[1]
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_priv2

    tags = {
        Name = "bigdata_priv_subnet2"
    } 
}

resource "aws_subnet" "bigdata_priv_subnet3" {
    availability_zone = data.aws_availability_zones.azlist.names[2]
    vpc_id = aws_vpc.bigdata.id
    cidr_block = var.vpc_subnet_priv3

    tags = {
        Name = "bigdata_priv_subnet3"
    } 
}



# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "bigdata_pub_rt" {
    vpc_id = aws_vpc.bigdata.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.bigdata_igw.id    
    }
    
    tags = {
        Name = "bigdata_pub_rt"
    }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "bigdata_rt_association1" {
    subnet_id = aws_subnet.bigdata_pub_subnet1.id
    route_table_id = aws_route_table.bigdata_pub_rt.id
}

resource "aws_route_table_association" "bigdata_rt_association2" {
    subnet_id = aws_subnet.bigdata_pub_subnet2.id
    route_table_id = aws_route_table.bigdata_pub_rt.id
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
