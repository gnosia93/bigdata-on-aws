![sqoop](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/sqoop.png)

아파치 스쿱(sqoop)은 관계형 데이터베이스와 하둡 사이에서 데이터 이관을 지원하는 소프트웨어로, 관계형 데이터베이스의 데이터를 HDFS, 하이브, Hbase에 임포트(import)하거나, 반대로 관계형 DB로 익스포트(export)할 수 있습니다. 스쿱은 클라우데라에서 개발했으며, 현재 아파치 오픈소스 프로젝트로 공개되어 있습니다. (현재는 deprecated 됨)


### 1. 실습 데이터 다운로드 ###

이번 실습에서는 하버드 데이터버스에서 제공하는 미 항공 데이터 샘플을 이용하여 sqoop 를 실습하도록 하겠습니다.(https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HG7NV7).  
ec2 인스턴스로 로그인 한 후 실습 데이터를 다운로드 합니다.

```
$ terraform output | grep ec2_public
ec2_public_ip = "ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com"

$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/

[ec2-user@ip-10-1-1-31 ~]$ mkdir -p data/sqoop
[ec2-user@ip-10-1-1-31 ~]$ cd data/sqoop/

[ec2-user@ip-10-1-1-31 sqoop]$ wget https://dataverse.harvard.edu/api/access/datafile/1374931 -O carriers.csv
```

### 2. PostgreSQL 오브젝트 생성 ###

테라폼 또는 AWS RDS 콘솔에서 PostgreSQL RDS 의 엔드포인트를 확인한다. 
```
$ terraform output | grep rds
rds_endpoint = "bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432"
```

psql 을 이용하여 RDS 로 로그인 한 후, 사용자 및 데이터베이스를 생성한다. DB 로그인 시 postgres 유저의 패스워드는 postgres 이다. 
```
[ec2-user@ip-10-1-1-31 ~]$ psql -h bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com -U postgres
Password for user postgres:
psql (9.2.24, server 13.3)
WARNING: psql version 9.2, server version 13.0.
         Some psql features might not work.
SSL connection (cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256)
Type "help" for help.

postgres=> create user airline password 'airline';
CREATE ROLE

postgres=> grant airline to postgres;
GRANT ROLE

postgres=> create database airline_db owner airline;
CREATE DATABASE

postgres=> \du
                                                               List of roles
         Role name         |                   Attributes                   |                          Member of
---------------------------+------------------------------------------------+--------------------------------------------------------------
 airline                   |                                                | {}
 pg_execute_server_program | Cannot login                                   | {}
 pg_monitor                | Cannot login                                   | {pg_read_all_settings,pg_read_all_stats,pg_stat_scan_tables}
 pg_read_all_settings      | Cannot login                                   | {}
 pg_read_all_stats         | Cannot login                                   | {}
 pg_read_server_files      | Cannot login                                   | {}
 pg_signal_backend         | Cannot login                                   | {}
 pg_stat_scan_tables       | Cannot login                                   | {}
 pg_write_server_files     | Cannot login                                   | {}
 postgres                  | Create role, Create DB                        +| {airline,rds_superuser}
                           | Password valid until infinity                  |
 rds_ad                    | Cannot login                                   | {}
 rds_iam                   | Cannot login                                   | {}
 rds_password              | Cannot login                                   | {}
 rds_replication           | Cannot login                                   | {}
 rds_superuser             | Cannot login                                   | {pg_monitor,pg_signal_backend,rds_replication,rds_password}
 rdsadmin                  | Superuser, Create role, Create DB, Replication+| {}
                           | Password valid until infinity                  |
 rdsrepladmin              | No inheritance, Cannot login, Replication      | {}
 rdstopmgr                 | Password valid until infinity                  | {pg_monitor}

postgres=> \l
                                  List of databases
    Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
------------+----------+----------+-------------+-------------+-----------------------
 airline_db | airline  | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 meta       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 rdsadmin   | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin
 template0  | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin          +
            |          |          |             |             | rdsadmin=CTc/rdsadmin
 template1  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
            |          |          |             |             | postgres=CTc/postgres
(6 rows)
```


### 3. 테이블 생성 및 데이터 로딩 ###

airline_db 연결시 airline 유저의 패스워드는 airline 이다. 테이블 생성 후, \copy 명령어를 이용하여 CSV 파일을 업로드 한다. 
```
postgres=> \c airline_db airline
Password for user airline:
psql (9.2.24, server 13.3)
WARNING: psql version 9.2, server version 13.0.
         Some psql features might not work.
SSL connection (cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256)
You are now connected to database "airline_db" as user "airline".

airline_db=> create table carriers
(
    code varchar(30) not null,
    description varchar(100) not null,
    primary key(code)
);
CREATE TABLE

airline_db=> alter table carriers owner to airline;
ALTER TABLE

airline_db=> \d+
                      List of relations
 Schema |   Name   | Type  |  Owner  |  Size   | Description
--------+----------+-------+---------+---------+-------------
 public | carriers | table | airline | 0 bytes |
(1 row)

airline_db=> \copy carriers from '/home/ec2-user/data/sqoop/carriers.csv' delimiter ',' null as 'NA' csv header;

airline_db=> select count(1) from carriers;
 count
-------
  1491
(1 row)

airline_db=> \q
```

### 4. sqoop import to hdfs ###

emr 마스터 노드로 로그인 한 후,  
```
$ terraform output 
Outputs:

airflow_public_ip = "ec2-52-79-178-219.ap-northeast-2.compute.amazonaws.com"
ec2_public_ip = "ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com"
emr_master_public_dns = "ec2-3-36-96-133.ap-northeast-2.compute.amazonaws.com"
msk_brokers = "b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092"
rds_endpoint = "bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432"


$ ssh -i ~/tf_key_bigdata.pem hadoop@ec2-3-36-96-133.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com (3.34.196.21)' can't be established.
ECDSA key fingerprint is SHA256:IiVTTs4lnxFzQHBPIBgCErqNLmQrE/oKUJSAbJTA+AM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com,3.34.196.21' (ECDSA) to the list of known hosts.

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

[hadoop@ip-10-1-1-99 ~]$ 
```
sqoop import 명령어를 이용하여 RDS 테이블 데이터를 hdfs 로 import 한다. 
-m 파라미터는 매퍼의 갯수로 여기서는 1 로 설정한다. 
```
[hadoop@ip-10-1-1-99 ~]$ sqoop import -D mapreduce.output.basename=carrier-`date +%Y-%m-%d` \
   --connect jdbc:postgresql://bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432/airline_db \
   --username airline \
   --password airline \
   --table carriers \
   --target-dir /tmp/workshop/carriers -m 1 


[hadoop@ip-10-1-1-99 ~]$ hadoop fs -ls -R /tmp/workshop/carriers
-rw-r--r--   1 hadoop hdfsadmingroup          0 2021-07-18 04:15 /tmp/workshop/carriers/_SUCCESS
-rw-r--r--   1 hadoop hdfsadmingroup      36285 2021-07-18 04:15 /tmp/workshop/carriers/carrier-2021-07-18-m-00000
```

### 5. 하이브 테이블 생성 ###

```
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

hive> create external table workshop.carriers (
  code          String,
  description   String
)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile
location '/tmp/workshop/carriers';   

hive> select * from workshop.carriers limit 5;
OK
02Q	Titan Airways
04Q	Tradewind Aviation
05Q	Comlux Aviation
06Q	Master Top Linhas Aereas Ltd.
07Q	Flair Airlines Ltd.
Time taken: 0.125 seconds, Fetched: 5 row(s)

hive> select count(1) from workshop.carriers;
Query ID = hadoop_20210718042408_1b421d3f-7465-4a4d-a22b-c13e29dc8e46
Total jobs = 1
Launching Job 1 out of 1
Status: Running (Executing on YARN cluster with App id application_1626574200222_0014)

----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      1          1        0        0       0       0
Reducer 2 ...... container     SUCCEEDED      1          1        0        0       0       0
----------------------------------------------------------------------------------------------
VERTICES: 02/02  [==========================>>] 100%  ELAPSED TIME: 4.46 s
----------------------------------------------------------------------------------------------
OK
1491
Time taken: 6.669 seconds, Fetched: 1 row(s)
```

참고로 하이브에서는 테이블 조회시 MR 작업을 수행하지 않고, 바로 데이터를 읽어오는 것을 확인할 수 있다. (select * from workshop.carriers limit 5;)


## 참고자료 ##

* [스쿱 튜토리얼](https://data-flair.training/blogs/apache-sqoop-tutorial/)

* https://stackoverflow.com/questions/26684643/error-must-be-member-of-role-when-creating-schema-in-postgresql

* [스쿱 + 카이트 + S3](https://www.thetopsites.net/article/58483546.shtml)
