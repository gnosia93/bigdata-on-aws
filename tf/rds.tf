

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "bigdata_db_subnet_grp" {
  name       = "bigdata-db-subnet-grp"
  subnet_ids = [ aws_subnet.bigdata_priv_subnet1.id, aws_subnet.bigdata_priv_subnet2.id ]

  tags = {
    Name = "bigdata_db_subnet_grp"
  }
}


resource "aws_security_group" "bigdata_rds_sg" {
    name = "bigdata_rds_sg"
    description = "bigdata_rds_sg"
    vpc_id = aws_vpc.bigdata.id

    ingress = [   
        {
            cidr_blocks = [ var.vpc_cidr_block ] 
            description = "rds ingress"
            from_port = 5432
            to_port = 5432
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        }
    ]

    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "rds egress"
            from_port = 0
            to_port = 0
            protocol = "-1"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        }
    ]   
    
    tags = {
        Name = "bigdata_rds_sg"
    }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_security_group
/*
resource "aws_db_security_group" "bigdata_db_sg" {
    name = "bigdata_db_sg"
    ingress {
        security_group_id = aws_security_group.bigdata_rds_sg.id
    }   
   
    tags = {
        Name = "bigdata_db_sg"
    }
}
*/


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "bigdata_rds" {
    identifier            = "bigdata-postgres" 
    allocated_storage     = 10
    max_allocated_storage = 100
    engine                = "postgres"
    engine_version        = "13.3"
    instance_class        = "db.m5.large"
    name                  = "meta"
    username              = "postgres"
    password              = "postgres"
    skip_final_snapshot   = true
    db_subnet_group_name  = aws_db_subnet_group.bigdata_db_subnet_grp.name
    vpc_security_group_ids = [ aws_security_group.bigdata_rds_sg.id ] 
}

output "rds_endpoint" {
    value = aws_db_instance.bigdata_rds.endpoint
}