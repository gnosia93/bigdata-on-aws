
### 1. 실습 데이터 다운로드 ###


ec2 인스턴스로 로그인해서 실습 데이터를 다운로드 합니다.

```
$ terraform output | grep ec2
ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/


wget https://dataverse.harvard.edu/api/access/datafile/1374918
```
