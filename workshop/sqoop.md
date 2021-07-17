이번 실습에서는 하버드 데이터버스에서 제공하는 미 항공 데이터 샘플을 이용하여 sqoop 를 실습하도록 하겠습니다. 
* https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HG7NV7
 
![hive-samle](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/hive-sample-data1.png)


### 1. 실습 데이터 다운로드 ###

ec2 인스턴스로 로그인 한 후 실습 데이터를 다운로드 합니다.

```
$ terraform output | grep ec2_public
ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/

[ec2-user@ip-10-1-1-31 ~]$ mkdir -p data/sqoop
[ec2-user@ip-10-1-1-31 ~]$ cd data/sqoop/

[ec2-user@ip-10-1-1-31 sqoop]$ wget https://dataverse.harvard.edu/api/access/datafile/1374931 -O carriers.csv
```

### 2. 데이터 전처리 하기 ###

sed 를 이용하여 csv 파일의 헤더와 각 필드의 쌍따옴표를 제거합니다. 

```
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' carriers.csv > carriers_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -i 's/"//g' carriers_new.csv
```
