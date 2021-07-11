# AMI 정보를 어떻게 출력하는지 ?
# amzn2-ami-hvm-2.0.20210303.0-x86_64-gp2 (ami-0e17ad9abf7e5c818)
# 이미지가 update되는 경우 최신 버전의 AMI 를 받아오게 된다. 
data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = [ "amazon" ]

    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "bigdata_ec2_sg" {
    name        = "bigdata_ec2_sg"
    description = "bigdata_ec2_sg"
    vpc_id = aws_vpc.bigdata.id

    ingress = [ 
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "ec2 ingress"
            from_port = 22
            to_port = 22
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
            description = "ec2 egress"
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
        Name = "bigdata_ec2_sg"
    }   
}


resource "aws_iam_role" "bigdata_ec2_service_role" {
  name = "bigdata_ec2_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bigdata_ec2_policy" {
  name = "bigdata_ec2_policy"
  role = aws_iam_role.bigdata_ec2_service_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bigdata_ec2_profile" {
  name = "bigdata_ec2_profile"
  role = aws_iam_role.bigdata_ec2_service_role.name
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "bigdata_ec2" {
    ami = data.aws_ami.amazon-linux-2.id
    associate_public_ip_address = true
    instance_type = "c5.xlarge"
    iam_instance_profile = aws_iam_instance_profile.bigdata_ec2_profile.name
    monitoring = true
    root_block_device {
        volume_size = "50"
    }
    key_name = var.key_pair
    vpc_security_group_ids = [ aws_security_group.bigdata_ec2_sg.id ]
    subnet_id = aws_subnet.bigdata_pub_subnet1.id
    user_data = <<_DATA
#! /bin/bash
yum install -y python37 git telnet
yum install -y postgresql
yum install -y java-1.8.0-openjdk-devel
sudo -u ec2-user curl -o /home/ec2-user/hadoop-3.2.1.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
sudo -u ec2-user curl -o /home/ec2-user/kafka_2.13-2.6.1.tgz https://archive.apache.org/dist/kafka/2.6.1/kafka_2.13-2.6.1.tgz
export JAVA_HOME=/usr/lib/jvm/java
export HADOOP_HOME=/home/ec2-user/hadoop-3.2.1
export KAFKA_HOME=/home/ec2-user/kafka_2.13-2.6.1
sudo -u ec2-user echo "export JAVA_HOME=/usr/lib/jvm/java" >> /home/ec2-user/.bash_profile 
sudo -u ec2-user echo "export HADOOP_HOME=/home/ec2-user/hadoop-3.2.1" >> /home/ec2-user/.bash_profile 
sudo -u ec2-user echo "export KAFKA_HOME=/home/ec2-user/kafka_2.13-2.6.1" >> /home/ec2-user/.bash_profile 
sudo -u ec2-user echo "export PATH=$PATH:$HADOOP_HOME/bin:$KAFKA_HOME/bin" >> /home/ec2-user/.bash_profile 
sudo -u ec2-user tar xvfz /home/ec2-user/hadoop-3.2.1.tar.gz -C /home/ec2-user
sudo -u ec2-user tar xvfz /home/ec2-user/kafka_2.13-2.6.1.tgz -C /home/ec2-user
sudo -u ec2-user echo "`date` ... done" > /home/ec2-user/done
_DATA

    tags = {
      "Name" = "bigdata_ec2"
    } 
}

output "ec2_public_ip" {
    value = aws_instance.bigdata_ec2.public_dns
}