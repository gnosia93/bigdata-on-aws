![terraform](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/terraform-1.png)



### 1. 테라폼 설치 ###

* homebrew 는 mac 용 소프트웨어 패키지 매니저로 테라폼을 설치하기 위해 필요합니다.
```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

* 테라폼을 brew 를 이용하여 설치합니다. 
```
$ brew install terraform
$ terraform -version
Terraform v1.0.7
on darwin_amd64
```


### 2. AWS CLI 설정 ###

테라폼은 HCL 기반으로 리소스를 선언 및 관리하는 오픈소스 IaC 도구로서, AWS 클라우드에 인프라를 배포하기 위해서는 AWS 계정이 반드시 필요합니다.  
테라폼이 AWS 의 API 를 호출하기 위해서는 API Acesss 키 설정이 필요한 데, 테라폼은 aws CLI 의 설정키, 또는 환경변수 그리고 자체적인 Access Key 설정값으로 부터 관련 정보를 참조 합니다.
이번 워크샵에서는 환경변수를 이용하여 테라폼에게 억세스 키 값을 전달하도록 하겠습니다. 

* 환경변수를 통한 전달 

아래와 같이 bash profile 에 억세스 키 정보를 추가하도록 합니다. 엑세스 키 정보는 AWS IAM 콘솔의 Users 메뉴의 유저별 Security Credentials 탭에서 확인 가능합니다.
만약 해당 유저의 억세스키 값이 발급되어 있지 않다면 아래의 URL 을 참고하여 억세스키를 먼저 발급 하십시오

[억세스 키 생성하기](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)

```
$ cd
$ vi .bash_profile

export aws_access_key_id = AAaaaaaaaaaaaaa                          <--- 억세스키 추가
export aws_secret_access_key = SSssssssssssssss                     <--- 시크리트 억세스키 추가 
export aws_region = "ap-northeast-2"                                <--- 리전 설정

$ . .bash_profile                                                   <--- 환경 변수 적용을 위해 .bash_profile 
```


### 3. 키페어 생성 ###

AWS EC2 콘솔의 keypair 화면으로 이동 한후, ssh 로그인용 키페어를 아래와 같이 생성합니다. 생성된 키페어 파일은 로컬 PC의 [다운로드] 라는 디렉토리에서 확인하실 수 있습니다.(파일명-tf_key_bigdata.pem)

![keypair-3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/keypair-3.png)

아래 명령어를 이용하여 생성한 키페어를 홈 디렉토리로 이동 시킵니다.

```
$ mv ~/Downloads/tf_key_bigdata.pem ~
```

### 4. 워크샵 리소스 생성 ###

리소스를 생성하기 위해 아래와 같이 git 레포지토리 부터 소스 코드를 로컬 PC 로 다운로드 받은 후, var.tf 파일의 your_ip_addr 와 key_pair 의 값을
여러분들의 환경에 맞게 수정합니다. 이때 your_ip_addr 값은 아래와 같이 네이버 검색창을 이용하여 조회하도록 합니다. 

![my-ip](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/my-ip.png)

```
$ cd 
$ git clone https://github.com/gnosia93/bigdata-on-aws.git
$ cd bigdata-on-aws/tf

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

### 5. 생성 리소스 확인 ###

AWS 콘솔로 로그인해서 아래 그림과 같이 ec2, emr, msk 및 rds 가 제대로 생성되어 있는지 확인합니다.  

* EC2
 
EC2 인스턴스 2대와 EMR 용 인스턴스 3대가 생성된 것을 확인하실 수 있습니다.   

![ec2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/ec2-1.png)

* EMR

![emr](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/emr.png)

* MSK

![msk](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/msk.png)

* RDS

![rds](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/rds.png)


### 6. 리소스 삭제하기 ###

실습을 완료한 경우, 아래 명령어를 이용하여 리소스를 삭제합니다. 
```
$ terraform destroy -auto-approve
```



