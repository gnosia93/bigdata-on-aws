resource "aws_security_group" "priv_sg" {
    vpc_id = aws_vpc.bigdata.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
resource "aws_cloudwatch_log_group" "bigdata_msk_log" {
    name = "msk_broker_logs"
}

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
        security_groups = [aws_security_group.priv_sg.id]
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

output "msk_zookeepers" {
    value = aws_msk_cluster.bigdata_msk.zookeeper_connect_string
}

output "msk_brokers" {
    value = aws_msk_cluster.bigdata_msk.bootstrap_brokers
}
