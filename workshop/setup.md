#### 1. 테라폼 설치 ####


#### 2. AWS CLI 설정 ####


#### 3. 키페어 생성 ####

AWS EC2 콘솔로 이동 후, ssh 로그인용 키페어를 아래와 같이 생성합니다. 



#### 4. 워크샵 리소스 생성 ####

리소스를 생성하기 위해 아래와 같이 git 레포지토리 부터 소스 코드를 로컬 PC 로 다운로드 받은 후, var.tf 파일의 your_ip_addr 와 key_pair 의 값을
여러분들의 환경에 맞게 수정합니다. 이때 your_ip_addr 값은 아래와 같이 네이버 검색창을 이용하여 조회하도록 합니다. 

![my-ip](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/my-ip.png)

```
$ cd 
$ git clone https://github.com/gnosia93/bigdata-on-aws.git

$ vi var.tf
variable "your_ip_addr" {
    type = string
    default = "218.238.107.63/32"       ## 네이버 검색창에서 "내아이피" 로 검색한 후, 결과값을 CIDR 형태로 입력.
}

variable "key_pair" {
    type = string
    default = "tf_key_bigdata"         ## 콘솔에서 생성한 키페어 명칭으로 변경.
}

$ terraform init
$ terraform apply -auto-approve
```

#### 5. 생성 리소스 확인 ####

AWS 콘솔로 로그인해서 아래 그림과 같이 ec2, emr, msk 및 rds 가 제대로 생성되어 있는지 확인합니다.  

* ec2


* emr


* msk


* rds
