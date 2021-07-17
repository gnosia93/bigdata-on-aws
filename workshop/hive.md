
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

### 2. 데이터 전처리 하기 ###

csv 파일의 헤더를 sed 를 이용하여 제거합니다. 

```
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2001.csv > 2001_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2002.csv > 2002_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2003.csv > 2003_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2004.csv > 2004_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2005.csv > 2005_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2006.csv > 2006_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2007.csv > 2007_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2008.csv > 2008_new.csv
```

### 3. hdfs 디렉토리 생성 ###

airline_delay 디렉토리를 hadoop 명령어를 이용하여 /tmp 디렉토리 밑에 생성한다. hdfs 의 /tmp 디렉토리의 경우 모든 유저들이 읽기 및 쓰기가 가능한 영역이다.
만약 /tmp 가 아닌 다른 디렉토리를 설정하는 경우 쓰기 권한이 없이 때문에 오류가 발생한다. 
```
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -mkdir -p /tmp/workshop/airline_delay
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -ls /tmp/workshop
Found 1 items
drwxr-xr-x   - ec2-user hdfsadmingroup          0 2021-07-17 01:27 /tmp/workshop/airline_delay





```

### 3. hive 테이블 생성 (external) ###


### 4. 데이터 조회하기 ###





## 참고자료 ##

* [PostgreSQL 메타스토어 사용하기](https://aws.amazon.com/ko/premiumsupport/knowledge-center/postgresql-hive-metastore-emr/)
* https://mkkim85.github.io/hadoop-hive-merge/

