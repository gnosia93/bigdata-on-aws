
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

[ec2-user@ip-10-1-1-31 ~]$ mkdir data
[ec2-user@ip-10-1-1-31 ~]$ cd data
[ec2-user@ip-10-1-1-31 data]$ mkdir hive
[ec2-user@ip-10-1-1-31 data]$ cd hive
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374917 -O 2008.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374918 -O 2007.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374922 -O 2006.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374923 -O 2005.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374925 -O 2004.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374926 -O 2003.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374927 -O 2002.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374928 -O 2001.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2008.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2007.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2006.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2005.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2004.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2003.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2002.csv.bz2
[ec2-user@ip-10-1-1-31 hive]$ bunzip2 2001.csv.bz2
```

### 2. hdfs 에 파일 업로드 ###

```
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -mkdir -p /raw/airline

```


### 3. HIVE 메타 스토어 설정 ###

* https://aws.amazon.com/ko/premiumsupport/knowledge-center/postgresql-hive-metastore-emr/

#### 3.1 emr 마스터 노드의 DNS 명칭을 조회합니다. #### 
```
$ terraform output | grep emr
emr_master_public_dns = ec2-13-125-200-36.ap-northeast-2.compute.amazonaws.com
```

#### 3.2 emr 마스터 노드에 로그인 하여, PostgreSQL RDS 에 메타 스토어를 생성합니다. #### 
```
$ ssh -i ~/.ssh/tf_key hadoop@ec2-13-125-200-36.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-13-125-200-36.ap-northeast-2.compute.amazonaws.com (13.125.200.36)' can't be established.
ECDSA key fingerprint is SHA256:klbH6+rNsLO3eglMLg6i70JL3X4vg4gm/7DpbudX3Wg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-13-125-200-36.ap-northeast-2.compute.amazonaws.com,13.125.200.36' (ECDSA) to the list of known hosts.
Last login: Mon Jul 12 09:49:26 2021

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
49 package(s) needed for security, out of 89 available
Run "sudo yum update" to apply all updates.

EEEEEEEEEEEEEEEEEEEE MMMMMMMM           MMMMMMMM RRRRRRRRRRRRRRR
E::::::::::::::::::E M:::::::M         M:::::::M R::::::::::::::R
EE:::::EEEEEEEEE:::E M::::::::M       M::::::::M R:::::RRRRRR:::::R
  E::::E       EEEEE M:::::::::M     M:::::::::M RR::::R      R::::R
  E::::E             M::::::M:::M   M:::M::::::M   R:::R      R::::R
  E:::::EEEEEEEEEE   M:::::M M:::M M:::M M:::::M   R:::RRRRRR:::::R
  E::::::::::::::E   M:::::M  M:::M:::M  M:::::M   R:::::::::::RR
  E:::::EEEEEEEEEE   M:::::M   M:::::M   M:::::M   R:::RRRRRR::::R
  E::::E             M:::::M    M:::M    M:::::M   R:::R      R::::R
  E::::E       EEEEE M:::::M     MMM     M:::::M   R:::R      R::::R
EE:::::EEEEEEEE::::E M:::::M             M:::::M   R:::R      R::::R
E::::::::::::::::::E M:::::M             M:::::M RR::::R      R::::R
EEEEEEEEEEEEEEEEEEEE MMMMMMM             MMMMMMM RRRRRRR      RRRRRR
```

