이번 실습에서는 하버드 데이터버스에서 제공하는 미 항공 데이터 샘플을 이용하여 hive 를 실습하도록 하겠습니다. 
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

[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/1374930 -O airports.csv
```

### 2. 데이터 전처리 하기 ###

sed 를 이용하여 csv 파일의 헤더와 각 필드의 쌍따옴표를 제거합니다. 

```
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2001.csv > 2001_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2002.csv > 2002_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2003.csv > 2003_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2004.csv > 2004_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2005.csv > 2005_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2006.csv > 2006_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2007.csv > 2007_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' 2008.csv > 2008_new.csv

[ec2-user@ip-10-1-1-31 hive]$ sed -e '1d' airports.csv > airports_new.csv
[ec2-user@ip-10-1-1-31 hive]$ sed -i 's/"//g' airports_new.csv
```
