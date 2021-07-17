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
```
[ec2-user@ip-10-1-1-31 sqoop]$ psql postgres
psql (13.0)
Type "help" for help.

postgres=# create user airline password 'airline';
CREATE ROLE

postgres=# create database airline_db owner = airline;
CREATE DATABASE

postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 airline   |                                                            | {}
 hive      |                                                            | {}
 soonbeom  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

postgres=# \l
                             List of databases
    Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges
------------+----------+----------+---------+-------+-----------------------
 airline_db | airline  | UTF8     | C       | C     |
 hive       | hive     | UTF8     | C       | C     |
 postgres   | soonbeom | UTF8     | C       | C     |
 template0  | soonbeom | UTF8     | C       | C     | =c/soonbeom          +
            |          |          |         |       | soonbeom=CTc/soonbeom
 template1  | soonbeom | UTF8     | C       | C     | =c/soonbeom          +
            |          |          |         |       | soonbeom=CTc/soonbeom
(5 rows)

```

