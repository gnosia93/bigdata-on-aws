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

# ubuntu image for airflow 
# ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026 (ami-007b7745d0725de95)
data "aws_ami" "ubuntu-20" {
    most_recent = true
    owners = [ "099720109477" ]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026*"]
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
            prefix_list_ids = [ "pl-e1a54088" ]
            security_groups = [ ]
            self = false
        },
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "ec2 ingress"
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ "pl-e1a54088" ]
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
sudo -u ec2-user echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$KAFKA_HOME/bin" >> /home/ec2-user/.bash_profile 
sudo -u ec2-user tar xvfz /home/ec2-user/hadoop-3.2.1.tar.gz -C /home/ec2-user
sudo -u ec2-user tar xvfz /home/ec2-user/kafka_2.13-2.6.1.tgz -C /home/ec2-user
sudo -u ec2-user echo "`date` ... done" > /home/ec2-user/done
_DATA

    tags = {
      "Name" = "bigdata_ec2"
    } 
}

resource "aws_instance" "bigdata_airflow" {
    ami = data.aws_ami.ubuntu-20.id
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
sudo apt-get update
sudo apt-get install pip -y
sudo pip install --upgrade pip
sudo apt-get install python-setuptools -y
sudo apt-get install python-dev -y
sudo apt-get install libmysqlclient-dev -y
sudo apt-get install libssl-dev -y
sudo apt-get install libkrb5-dev -y
sudo apt-get install libsasl2-dev -y
sudo pip install apache-airflow
sudo pip install apache-airflow-providers-postgres
sudo pip install apache-airflow-providers-apache-spark
sudo -u ubuntu echo 'export AIRFLOW_HOME=~/airflow' >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo 'alias python=python3' >> /home/ubuntu/.bash_profile    
sudo -u ubuntu mkdir -p /home/ubuntu/airflow/dags
sudo -u ubuntu airflow db init
sudo -u ubuntu echo "AUTH_ROLE_PUBLIC = 'Admin'" >> /home/ubuntu/airflow/webserver_config.py
sudo -u ubuntu sed -i s/'load_examples = True'/'load_examples = False'/g /home/ubuntu/airflow/airflow.cfg
sudo apt-get install -y postgresql-client
sudo -u ubuntu wget http://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -P /home/ubuntu
sudo -u ubuntu tar xvfz /home/ubuntu/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C /home/ubuntu
sudo -u ubuntu wget https://mirror.navercorp.com/apache/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz -P /home/ubuntu
sudo -u ubuntu tar xvfz /home/ubuntu/spark-3.1.2-bin-hadoop3.2.tgz -C /home/ubuntu
sudo -u ubuntu wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz -P /home/ubuntu
sudo -u ubuntu tar xvfz /home/ubuntu/hadoop-3.2.1.tar.gz -C /home/ubuntu
sudo apt install -y openjdk-8-jdk-headless
export HADOOP_HOME=/home/ubuntu/hadoop-3.2.1
export SPARK_HOME=/home/ubuntu/spark-3.1.2-bin-hadoop3.2
export SQOOP_HOME=/home/ubuntu/sqoop-1.4.7.bin__hadoop-2.6.0
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop        
sudo -u ubuntu echo "export HADOOP_HOME=/home/ubuntu/hadoop-3.2.1" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export SPARK_HOME=/home/ubuntu/spark-3.1.2-bin-hadoop3.2" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export SQOOP_HOME=/home/ubuntu/sqoop-1.4.7.bin__hadoop-2.6.0" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> /home/ubuntu/.bash_profile
sudo -u ubuntu echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$SPARK_HOME/bin:\$SQOOP_HOME/bin" >> /home/ubuntu/.bash_profile
sudo -u ubuntu wget https://repo1.maven.org/maven2/commons-lang/commons-lang/2.6/commons-lang-2.6.jar -P /home/ubuntu/sqoop-1.4.7.bin__hadoop-2.6.0/lib
sudo -u ubuntu wget https://jdbc.postgresql.org/download/postgresql-42.2.23.jar -P /home/ubuntu/sqoop-1.4.7.bin__hadoop-2.6.0/lib   
sudo -u ubuntu wget www.scala-lang.org/files/archive/scala-2.12.12.deb -P /home/ubuntu
sudo dpkg -i /home/ubuntu/scala-2.12.12.deb
sudo -u ubuntu wget https://github.com/sbt/sbt/releases/download/v1.2.8/sbt-1.2.8.tgz -P /home/ubuntu
sudo -u ubuntu tar xvfz /home/ubuntu/sbt-1.2.8.tgz -C /home/ubuntu
sudo -u ubuntu echo "export PATH=\$PATH:/home/ubuntu/sbt/bin" >> /home/ubuntu/.bash_profile
sudo -u ubuntu airflow webserver -D
sudo -u ubuntu airflow scheduler -D
sudo -u ubuntu touch /home/ubuntu/done
_DATA

    tags = {
      "Name" = "bigdata_airflow"
    } 
}



output "ec2_public_ip" {
    value = aws_instance.bigdata_ec2.public_dns
}

output "airflow_public_ip" {
    value = aws_instance.bigdata_airflow.public_dns
}
