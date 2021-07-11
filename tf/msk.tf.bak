resource "aws_security_group" "bigdata_msk_sg" {
    name        = "bigdata_msk_sg"
    description = "bigdata_msk_sg"
    vpc_id = aws_vpc.bigdata.id

    ingress = [ 
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "msk ingress"
            from_port = 9092
            to_port = 9092
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        },
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "msk ingress"
            from_port = 2181
            to_port = 2181
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
            description = "msk egress"
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
        Name = "bigdata_msk_sg"
    }   
}

resource "aws_cloudwatch_log_group" "bigdata_msk_log" {
    name = "msk_broker_logs"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
resource "aws_msk_cluster" "bigdata_msk" {
    cluster_name = "bigdata-msk"
    kafka_version = "2.6.1"
    number_of_broker_nodes = 3

    broker_node_group_info {
        instance_type = "kafka.m5.large"
        ebs_volume_size = 100
        client_subnets = [
            aws_subnet.bigdata_priv_subnet1.id,
            aws_subnet.bigdata_priv_subnet2.id,
            aws_subnet.bigdata_priv_subnet3.id
        ]
        security_groups = [aws_security_group.bigdata_msk_sg.id]
    }

    encryption_info {
        encryption_in_transit {
            client_broker = "PLAINTEXT"
            in_cluster = "false"
        }
    }

    logging_info {
        broker_logs {
            cloudwatch_logs {
                enabled = true
                log_group = aws_cloudwatch_log_group.bigdata_msk_log.name
            }
        }
    }

    tags = {
        Name = "bigdata_msk"
    }
}

/*
output "msk_zookeepers" {
    value = aws_msk_cluster.bigdata_msk.zookeeper_connect_string
}
*/

output "msk_brokers" {
    value = aws_msk_cluster.bigdata_msk.bootstrap_brokers
}
