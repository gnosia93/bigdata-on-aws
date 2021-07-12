#### 1. 테라폼 설치 ####


#### 2. AWS CLI 설정 ####


#### 3. 키페어 생성 ####

AWS EC2 콘솔로 이동 후, ssh 로그인용 키페어를 아래와 같이 생성합니다. 생성된 키페어 파일은 로컬 PC의 [다운로드] 라는 디렉토리에서 확인하실 수 있습니다.(파일명-tf_key_bigdata.pem)

![keypair-3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/keypair-3.png)

아래 명령어를 이용하여 생성한 키페어를 홈 디렉토리로 이동 시킵니다.

```
$ mv ~/Downloads/tf_key_bigdata.pem ~
```

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
```


IP 주소와 키페어 값을 변경한 다음 테라폼을 이용하여 워크샵용 리소스를 다음과 같이 생성합니다. 리소스가 정상적으로 생성된 경우 아래에 보이는 바와 같이 Outputs: 항목에서 생성된 리소스들의 접속 정보를 확인할 수 있습니다. 리소스 생성이 완료되기 까지 약 30분의 시간이 소요됩니다. 

```
$ terraform init
$ terraform apply -auto-approve

...
aws_msk_cluster.bigdata_msk: Still creating... [25m50s elapsed]
aws_msk_cluster.bigdata_msk: Still creating... [26m0s elapsed]
aws_msk_cluster.bigdata_msk: Creation complete after 26m5s [id=arn:aws:kafka:ap-northeast-2:509076023497:cluster/bigdata-msk/47592988-64da-4312-bb3b-80f98d034f19-2]

Apply complete! Resources: 28 added, 0 changed, 0 destroyed.

Outputs:

ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
emr_master_public_dns = ec2-3-36-108-41.ap-northeast-2.compute.amazonaws.com
msk_brokers = b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
rds_endpoint = bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432

$ 
```

#### 5. 생성 리소스 확인 ####

AWS 콘솔로 로그인해서 아래 그림과 같이 ec2, emr, msk 및 rds 가 제대로 생성되어 있는지 확인합니다.  

* ec2


* emr


* msk


* rds
