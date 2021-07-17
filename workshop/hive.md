
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

### 4. hdfs 파일 복사 ###

아래 예제에서 처럼 csv 파일들을 hdfs 로 복사한 후, -head 명령어를 이용하여 복사된 파일의 내용을 확인한다.  

```
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -put -f 2007_new.csv /tmp/workshop/airline_delay/2007.csv
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -put -f 2008_new.csv /tmp/workshop/airline_delay/2008.csv

[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -ls -R /tmp/workshop
drwxr-xr-x   - ec2-user hdfsadmingroup          0 2021-07-17 01:33 /tmp/workshop/airline_delay
-rw-r--r--   3 ec2-user hdfsadmingroup  702878193 2021-07-17 01:32 /tmp/workshop/airline_delay/2007.csv
-rw-r--r--   3 ec2-user hdfsadmingroup  234052199 2021-07-17 01:33 /tmp/workshop/airline_delay/2008.csv

[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -head /tmp/workshop/airline_delay/2008.csv
Year,Month,DayofMonth,DayOfWeek,DepTime,CRSDepTime,ArrTime,CRSArrTime,UniqueCarrier,FlightNum,TailNum,ActualElapsedTime,CRSElapsedTime,AirTime,ArrDelay,DepDelay,Origin,Dest,Distance,TaxiIn,TaxiOut,Cancelled,CancellationCode,Diverted,CarrierDelay,WeatherDelay,NASDelay,SecurityDelay,LateAircraftDelay
2008,1,3,4,1343,1325,1451,1435,WN,588,N240WN,68,70,55,16,18,HOU,LIT,393,4,9,0,,0,16,0,0,0,0
2008,1,3,4,1125,1120,1247,1245,WN,1343,N523SW,82,85,71,2,5,HOU,MAF,441,3,8,0,,0,NA,NA,NA,NA,NA
2008,1,3,4,2009,2015,2136,2140,WN,3841,N280WN,87,85,71,-4,-6,HOU,MAF,441,2,14,0,,0,NA,NA,NA,NA,NA
2008,1,3,4,903,855,1203,1205,WN,3,N308SA,120,130,108,-2,8,HOU,MCO,848,5,7,0,,0,NA,NA,NA,NA,NA
2008,1,3,4,1423,1400,1726,1710,WN,25,N462WN,123,130,107,16,23,HOU,MCO,848,6,10,0,,0,16,0,0,0,0
2008,1,3,4,2024,2020,2325,2325,WN,51,N483WN,121,125,101,0,4,HOU,MCO,848,13,7,0,,0,NA,NA,NA,NA,NA
2008,1,3,4,1753,1745,2053,2050,WN,940,N493WN,120,125,107,3,8,HOU,MCO,848,6,7,0,,0,NA,NA,NA,NA,NA
2008,1,3,4,622,620,935,930,WN,2621,N266WN,133,130,107,5,[ec2-user@ip-10-1-1-31 hive]$
```

### 4. hive external 테이블 생성  ###

hive CLI 로 로그인하여 아래와 같이 external 테이블을 생성한다. 





### 5. 데이터 조회하기 ###

hive 테이블로 부터 데이터를 조회한다. 





## 참고자료 ##

* [PostgreSQL 메타스토어 사용하기](https://aws.amazon.com/ko/premiumsupport/knowledge-center/postgresql-hive-metastore-emr/)
* https://mkkim85.github.io/hadoop-hive-merge/

