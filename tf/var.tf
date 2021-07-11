/*
    $ terraform init
    $ terraform apply -auto-approve
    $ terraform destroy
*/

variable "your_ip_addr" {
    type = string
    default = "218.238.107.0/24"       ## 네이버에서 "내아이피" 로 검색한 후, 결과값을 CIDR 형태로 입력.
}

variable "vpc_subnet_pub1" { 
    type = string
    default = "10.1.0.0/24"       
}

variable "vpc_subnet_pri1" { 
    type = string
    default = "10.1.100.0/24"       
}