/*
    $ terraform init
    $ terraform apply --auto-approve
    $ terraform destroy
*/

variable "your_ip_addr" {
    type = string
    default = "218.238.107.0/24"       ## 네이버에서 "내아이피" 로 검색한 후, 결과값을 CIDR 형태로 입력.
}

variable "key_pair" {
    type = string
    default = "tf_key_bigdata"                ## 콘솔에서 생성한 키페어 명칭으로 변경.
}


############################### Don't modify beflows  ##################################

variable "vpc_cidr_block" {
    type = string
    default = "10.1.0.0/16"       
}

variable "vpc_subnet_pub1" { 
    type = string
    default = "10.1.1.0/24"       
}

variable "vpc_subnet_pub2" { 
    type = string
    default = "10.1.2.0/24"       
}

variable "vpc_subnet_pub3" { 
    type = string
    default = "10.1.3.0/24"       
}

variable "vpc_subnet_priv1" { 
    type = string
    default = "10.1.101.0/24"       
}

variable "vpc_subnet_priv2" { 
    type = string
    default = "10.1.102.0/24"       
}

variable "vpc_subnet_priv3" { 
    type = string
    default = "10.1.103.0/24"       
}
