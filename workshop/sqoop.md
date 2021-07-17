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

### 3. PostgreSQL 데이터 로딩 ###

테라폼 또는 AWS RDS 콘솔에서 PostgreSQL RDS 의 엔드포인트를 확인한다. 
```
$ terraform output | grep rds
rds_endpoint = bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432
```

psql 을 이용하여 사용자, 데이터베이스, 테이블을 생성하고 copy 명령어를 이용하여 데이터를 로딩한다. 
postgres 유저의 패스워드는 postgres 이다. 
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


## 참고자료 ##

* https://stackoverflow.com/questions/26684643/error-must-be-member-of-role-when-creating-schema-in-postgresql
