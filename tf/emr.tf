/*
NOTE on EMR-Managed security groups:
These security groups will have any missing inbound or outbound access rules added and maintained by AWS, 
to ensure proper communication between instances in a cluster. 
The EMR service will maintain these rules for groups provided in emr_managed_master_security_group and 
emr_managed_slave_security_group; 
attempts to remove the required rules may succeed, only for the EMR service to re-add them in a matter of minutes. 
This may cause Terraform to fail to destroy an environment that contains an EMR cluster, 
because the EMR service does not revoke rules added on deletion, leaving a cyclic dependency 
between the security groups that prevents their deletion. 
To avoid this, use the revoke_rules_on_delete optional attribute for any Security Group used in 
emr_managed_master_security_group and emr_managed_slave_security_group. 
See Amazon EMR-Managed Security Groups for more information about the EMR-managed security group rules.
*/

resource "aws_security_group" "bigdata_emr_sg" {
    vpc_id = aws_vpc.bigdata.id

    ingress = [ 
        {
            cidr_blocks = [ var.your_ip_addr, var.vpc_cidr_block ] 
            description = "emr ingress"
            from_port = 0
            to_port = 0
            protocol = "-1"
            ipv6_cidr_blocks = [ ]
            prefix_list_ids = [ ]
            security_groups = [ ]
            self = false
        }
    ]

    egress = [ 
        {
            cidr_blocks = [ "0.0.0.0/0" ]
            description = "emr egress"
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
        Name = "bigdata_emr_sg"
    }   
}


# IAM Role for EC2 Instance Profile
resource "aws_iam_role" "iam_emr_profile_role" {
  name = "iam_emr_profile_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_emr_profile_policy" {
  name = "iam_emr_profile_policy"
  role = aws_iam_role.iam_emr_profile_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "cloudwatch:*",
            "ec2:Describe*",
            "elasticmapreduce:Describe*",
            "elasticmapreduce:ListBootstrapActions",
            "elasticmapreduce:ListClusters",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ListInstances",
            "elasticmapreduce:ListSteps",
            "rds:Describe*",
            "s3:*",
            "sdb:*",
            "sns:*",
            "sqs:*"
        ]
    }]
}
EOF
}


resource "aws_iam_instance_profile" "bigdata_emr_profile" {
    name = "bigdata_emr_profile"
    role = aws_iam_role.iam_emr_profile_role.name
}



# IAM role for EMR Service
resource "aws_iam_role" "iam_emr_service_role" {
  name = "iam_emr_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name = "iam_emr_service_policy"
  role = aws_iam_role.iam_emr_service_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CancelSpotInstanceRequests",
            "ec2:CreateNetworkInterface",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteTags",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeNetworkAcls",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribePrefixLists",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:DescribeSpotPriceHistory",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcEndpointServices",
            "ec2:DescribeVpcs",
            "ec2:DetachNetworkInterface",
            "ec2:ModifyImageAttribute",
            "ec2:ModifyInstanceAttribute",
            "ec2:RequestSpotInstances",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:DeleteVolume",
            "ec2:DescribeVolumeStatus",
            "ec2:DescribeVolumes",
            "ec2:DetachVolume",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "s3:CreateBucket",
            "s3:Get*",
            "s3:List*",
            "sdb:BatchPutAttributes",
            "sdb:Select",
            "sqs:CreateQueue",
            "sqs:Delete*",
            "sqs:GetQueue*",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage"
        ]
    }]
}
EOF
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster
# https://stackoverflow.com/questions/65943872/how-to-deploy-emr-terraform-using-terraform-a-simple-out-of-the-box-working-
resource "aws_emr_cluster" "bigdata_emr" {
    
    # explict dependency check.
    # due to routing table issue - before emr is lauching, internet gw must be attached to VPC.
    depends_on = [aws_internet_gateway.bigdata_igw]                             

    name = "bigdata-emr"
    release_label = "emr-6.3.0"
    applications = ["hadoop", "hive", "zookeeper", "sqoop", "zeppelin", "hbase", "presto", "hue", "spark"]

    termination_protection = "false"
    ec2_attributes {
        subnet_id = aws_subnet.bigdata_pub_subnet1.id
        emr_managed_master_security_group = aws_security_group.bigdata_emr_sg.id
        emr_managed_slave_security_group = aws_security_group.bigdata_emr_sg.id
        instance_profile = aws_iam_instance_profile.bigdata_emr_profile.arn
        key_name = var.key_pair
    }

    master_instance_group {
        instance_type = "m5.2xlarge"
    }

    core_instance_group {
        instance_type = "c5.2xlarge"
        instance_count = 2

        ebs_config {
            size = "40"
            type = "gp2"
            volumes_per_instance = 1
        }      
    }

    ebs_root_volume_size = 40
    service_role = aws_iam_role.iam_emr_service_role.arn    

    tags = {
      "Name" = "bigdata_emr"
    } 
}

output "emr_master_public_dns" {
    value = aws_emr_cluster.bigdata_emr.master_public_dns
}
