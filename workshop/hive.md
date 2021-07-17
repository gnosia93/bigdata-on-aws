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

[ec2-user@ip-10-1-1-31 hive]$ wget https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/HG7NV7/XTPZZY -O airports.csv
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

airline_delay 디렉토리를 아래와 같이 생성합니다. 실행 유저가 hadoop 이 아닌 ec2-user 이므로 airline_delay 디렉토리는 쓰기가 가능 한 /tmp 디렉토리에 생성합니다. 
```
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -mkdir -p /tmp/workshop/airline_delay
[ec2-user@ip-10-1-1-31 hive]$ hadoop fs -ls /tmp/workshop
Found 1 items
drwxr-xr-x   - ec2-user hdfsadmingroup          0 2021-07-17 01:27 /tmp/workshop/airline_delay
```

### 4. hdfs 파일 복사 ###

아래 예제에서 처럼 csv 파일들을 hdfs 로 복사한 후, -head 명령어를 이용하여 복사된 파일의 내용을 확인합니다. 가급적 모든 파일을 hdfs 로 업로드 하는 것을 권장합니다. 

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

### 5. hive 테이블 생성  ###

emr 마스터 노드로 가서 hive 클라이언트를 이용하여 workshop 데이터베이스 및 airline_delay 외부 테이블을 생성합니다. 외부 테이블의 경우 hive 에서 테이블을 삭제하더라도 하이브의 메타 데이터만 삭제될 뿐, hdfs 에 존재하는 파일은 삭제되지 않습니다. 

```
$ ssh -i ~/.ssh/tf_key hadoop@ec2-52-79-231-111.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-52-79-231-111.ap-northeast-2.compute.amazonaws.com (52.79.231.111)' can't be established.
ECDSA key fingerprint is SHA256:Q0WmbNlE+Jomh5FAPgmuaKw2ci2efDQXF4o0XeMyRrM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-52-79-231-111.ap-northeast-2.compute.amazonaws.com,52.79.231.111' (ECDSA) to the list of known hosts.
Last login: Sat Jul 17 01:37:54 2021

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
62 package(s) needed for security, out of 103 available
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


[hadoop@ip-10-1-1-136 ~]$ hive
Hive Session ID = 31dea7d2-4353-419a-8321-5c442833865f

Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j2.properties Async: false
Hive Session ID = c2605b66-b002-4992-a187-169596f9a319

hive> create database if not exists workshop;
OK
Time taken: 0.053 seconds

hive> show databases;
OK
default
workshop
Time taken: 0.021 seconds, Fetched: 2 row(s)

hive> CREATE EXTERNAL TABLE workshop.airline_delay (
  Year INT, Month INT, 
  DayofMont INT, DayOfWeek INT, 
  DepTime INT, CRSDepTime INT, 
  ArrTime INT, CRSArrTime INT, 
  UniqueCarrier STRING, FlightNum INT, 
  TaiNum STRING, ActualElapsedTime INT, 
  CRSElapsedTime INT, AirTime INT, 
  ArrDelay INT, DepDelay INT, 
  Origin STRING, Dest STRING, 
  Distance INT, TaxiIn INT, 
  TaxiOut INT, Cancelled INT, 
  CancellationCode STRING COMMENT 'A=carrier, B=weather, C=NAS, D=security', 
  Diverted INT COMMENT '1=yes, 0=no', 
  CarrierDelay STRING, 
  WeatherDelay STRING, 
  NASDelay STRING, 
  SecurityDelay STRING, 
  LateAircraftDelay STRING) 
-- PARTITIONED BY (delayYear INT) 
  ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
  LINES TERMINATED BY '\n' 
  STORED AS TEXTFILE
  LOCATION '/tmp/workshop/airline_delay';   
```

### 6. 데이터 조회하기 ###

생성된 airline_delay 테이블에 대한 카운트 및 select 문장을 아래와 같이 실행합니다. hive QL 은 일반 SQL 문장과 비슷한 쿼리  지원합니다. 
```
hive> select count(1) from workshop.airline_delay;
Query ID = hadoop_20210717020638_e71d6403-5216-4f5b-840c-fb397fbec789
Total jobs = 1
Launching Job 1 out of 1
Status: Running (Executing on YARN cluster with App id application_1626484111706_0004)

----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      4          4        0        0       0       0
Reducer 2 ...... container     SUCCEEDED      1          1        0        0       0       0
----------------------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 7.55 s
----------------------------------------------------------------------------------------------
OK
9842432
Time taken: 8.333 seconds, Fetched: 1 row(s)

hive> describe workshop.airline_delay;
OK
year                	int
month               	int
dayofmont           	int
dayofweek           	int
deptime             	int
crsdeptime          	int
arrtime             	int
crsarrtime          	int
uniquecarrier       	string
flightnum           	int
tainum              	string
actualelapsedtime   	int
crselapsedtime      	int
airtime             	int
arrdelay            	int
depdelay            	int
origin              	string
dest                	string
distance            	int
taxiin              	int
taxiout             	int
cancelled           	int
cancellationcode    	string              	A=carrier, B=weather, C=NAS, D=security
diverted            	int                 	1=yes, 0=no
carrierdelay        	string
weatherdelay        	string
nasdelay            	string
securitydelay       	string
lateaircraftdelay   	string
Time taken: 0.045 seconds, Fetched: 29 row(s)


hive> set hive.cli.print.header=true;
hive> select cancellationcode as code, 
(case
   when cancellationcode = 'A' then 'carrier'
   when cancellationcode = 'B' then 'weather' 
   when cancellationcode = 'C' then 'NAS'
   when cancellationcode = 'D' then 'security'
end) as cause, 
count(1) as cnt 
from workshop.airline_delay 
group by cancellationcode;

Query ID = hadoop_20210717021836_805c4d35-3976-4146-8c53-37b149a36375
Total jobs = 1
Launching Job 1 out of 1
Status: Running (Executing on YARN cluster with App id application_1626484111706_0004)

----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      4          4        0        0       0       0
Reducer 2 ...... container     SUCCEEDED      1          1        0        0       0       0
----------------------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 8.48 s
----------------------------------------------------------------------------------------------
OK
code	cause	cnt
	NULL	9617241
A	carrier	92854
B	weather	87680
C	NAS	44612
D	security	45
Time taken: 9.234 seconds, Fetched: 5 row(s)
```

### 7. 하이브 트랜잭션 ###

update 와 delete 를 지원하지 않는 hdfs 와는 달리 하이브의 경우 테이블에 대한 update 및 delete 오퍼레이션을 지원합니다. 
default 설정은 non transaction 모드 이므로, 트랜잭션 지원이 필요한 테이블에 대해서는 명시적으로 트랜잭션 속성을 선언하고, 저장 타입 역시 orc 와 같은 트랜잭션을 지원하는 파일 포맷으로 변경해야 합니다.  

student 테이블을 생성한 후, 아래와 같이 3건의 레코드를 입력한 후, hdfs 의 파일 내역을 관찰합니다. 
```
hive> set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
hive> set hive.support.concurrency=true;
hive> create table student 
( 
  id int, 
  name string, 
  primary key(id) disable novalidate 
) 
stored as orc 
tblproperties ( "transactional" = "true" );

hive> insert into student values (1, 'aaa');
hive> insert into student values (2, 'bbb');
hive> insert into student values (3, 'ccc');

hive> select * from student;
OK
1	aaa
2	bbb
3	ccc
Time taken: 0.106 seconds, Fetched: 3 row(s)

hive> !hadoop fs -ls -R /user/hive/warehouse/student;
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        694 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        695 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        691 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/bucket_00000
```

아래와 같이 student 테이블을 업데이트 한 후, 테이블 데이터 및 hdfs 의 변경내역을 조회합니다. 
```
hive> update student set name = 'ccc2' where id = 3;
Query ID = hadoop_20210717033319_b1066d78-4062-4623-83e7-547efd4f6c4a
Total jobs = 1
Launching Job 1 out of 1
Status: Running (Executing on YARN cluster with App id application_1626484111706_0014)

----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      1          1        0        0       0       0
Reducer 2 ...... container     SUCCEEDED      2          2        0        0       0       0
----------------------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 3.71 s
----------------------------------------------------------------------------------------------
Loading data to table default.student
OK
Time taken: 4.672 seconds

hive> select * from student;
OK
1	aaa
2	bbb
3	ccc2
Time taken: 0.101 seconds, Fetched: 3 row(s)

hive> !hadoop fs -ls -R /user/hive/warehouse/student;
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        694 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        694 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        695 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        691 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        707 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000/bucket_00000
```

이번에는 id 값이 2인 레코드를 삭제한 후, hdfs 상의 변경 내역을 관찰합니다. 
```
hive> delete from student where id = 2;
Query ID = hadoop_20210717033717_1ee9f593-4d97-4048-8dca-b12b734ce9a6
Total jobs = 1
Launching Job 1 out of 1
Status: Running (Executing on YARN cluster with App id application_1626484111706_0014)

----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      1          1        0        0       0       0
Reducer 2 ...... container     SUCCEEDED      2          2        0        0       0       0
----------------------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 5.00 s
----------------------------------------------------------------------------------------------
Loading data to table default.student
OK
Time taken: 5.784 seconds
hive> select * from student;
OK
1	aaa
3	ccc2
Time taken: 0.092 seconds, Fetched: 2 row(s)

hive> !hadoop fs -ls -R /user/hive/warehouse/student;
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        694 2021-07-17 03:33 /user/hive/warehouse/student/delete_delta_0000004_0000004_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:37 /user/hive/warehouse/student/delete_delta_0000005_0000005_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:37 /user/hive/warehouse/student/delete_delta_0000005_0000005_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        689 2021-07-17 03:37 /user/hive/warehouse/student/delete_delta_0000005_0000005_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        694 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000001_0000001_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        695 2021-07-17 03:29 /user/hive/warehouse/student/delta_0000002_0000002_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        691 2021-07-17 03:30 /user/hive/warehouse/student/delta_0000003_0000003_0000/bucket_00000
drwxr-xr-x   - hadoop hdfsadmingroup          0 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000
-rw-r--r--   1 hadoop hdfsadmingroup          1 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000/_orc_acid_version
-rw-r--r--   1 hadoop hdfsadmingroup        707 2021-07-17 03:33 /user/hive/warehouse/student/delta_0000004_0000004_0000/bucket_00000
```

### 8. 하이브 인덱스 ###

```
hive> show databases;
OK
default
workshop
Time taken: 0.021 seconds, Fetched: 2 row(s)

hive> use workshop;
OK
Time taken: 0.026 seconds

hive> show tables;
OK
airline_delay
Time taken: 0.021 seconds, Fetched: 1 row(s)

hive>

```


## 참고자료 ##

* [하이브 트랜잭션](https://118k.tistory.com/688)
* [하이브 JOB KILL하기](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/yarn.md)
* [PostgreSQL 메타스토어 사용하기](https://aws.amazon.com/ko/premiumsupport/knowledge-center/postgresql-hive-metastore-emr/)
* https://mkkim85.github.io/hadoop-hive-merge/
* https://sites.google.com/site/hadoopbigdataoverview/hive-errors-1/failed-semanticexception-error-10294-attempt-to-do-update-or-delete-using-transaction-manager-that-does-not-support-these-operations
