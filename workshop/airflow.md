### 1. airflow 잡 스팩 (airflow_workshop_job) ###

* database operator - dummmy 레코드 gen (약 2100만건, 생성 소요시간 30초)
* sqoop operator - import data into hadoop 
* spark operator - summary spark job with hdfs
  - spark job 's output destination is hdfs
* 실행주기 - 매일
 
``` 
(중요) - 에어플로우 마스터 노드에 spark 및 sqoop 프로그램 설치가 필요하다. spark 의경우 emr 클러스터의 클라이언트로 동작하게 되지만, 
단순 커맨드 라인 인터페이스인 sqoop 의 경우 어찌 보면 중복 설치의 개념이긴 하다.
에어 플로우 ssh operator 를 사용하는 경우 이러한 문제를 방지할 순 있으나, ssh public key 를 에어플로우 서버에 올려놔야 해서 보안상 
문제가 발생할 소지가 있으므로, 에어플로우 마스터 노드에 spark 과 sqoop 을 설치하도록 한다. 
두 소프트웨어의 설치는 terraform 에서 자동으로 실행된다. 
```

[스쿱 실행 명령어]
```
$ HADOOP_USER_NAME=hdfs sqoop import \
   --connect jdbc:postgresql://bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432/airline_db \
   --username airline \
   --password airline \
   --table tbl_airflow_dummy \
   --target-dir hdfs://ec2-13-125-218-93.ap-northeast-2.compute.amazonaws.com:8020/tmp/airflow \
   --bindir . \
   --split-by line -m 4 \
   --delete-target-dir
```
--append 추가하기
--delete-target-dir 덮어쓰기

### 2. hadoop 설정하기 ###

core-site.xml 파일을 편집해서 fs.defaultFS 값을 여러분들의 emr 주소로 변경합니다. 

```
$ terraform output | grep airflow
airflow_public_ip = ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/.ssh/tf_key ubuntu@ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com (13.125.226.210)' can't be established.
ECDSA key fingerprint is SHA256:APd2pTzZPa7aurbP4kUvYF72GREBsDca6kOxw3EjQJA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com,13.125.226.210' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1029-aws x86_64)

ubuntu@ip-10-1-1-93:~$ cd $HADOOP_HOME/etc/hadoop

ubuntu@ip-10-1-1-93:~$ vi core-site.xml
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://ec2-13-125-218-93.ap-northeast-2.compute.amazonaws.com:8020</value>       # 여러분들의 emr 마스터 노드 주소로 변경하세요.
        </property>
</configuration>


$ cd /Users/soonbeom/analytics/sqoop-1.4.7.bin__hadoop-2.6.0
$ cp conf/sqoop-env-template.sh conf/sqoop-env.sh
$ vi conf/sqoop-env.sh
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME


ubuntu@ip-10-1-1-198:~$ cp $SQOOP_HOME/conf/sqoop-env-template.sh $SQOOP_HOME/conf/sqoop-env.sh
ubuntu@ip-10-1-1-198:~$ echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> $SQOOP_HOME/conf/sqoop-env.sh
ubuntu@ip-10-1-1-198:~$ echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> $SQOOP_HOME/conf/sqoop-env.sh

```

### 3. airflow 잡 등록하기 ###

에어플로우에서 잡을 등록하는 방법은 의외로 간단합니다. 잡 로직을 구현한 파이썬 파일을 $AIRFLOW_HOME/dags/ 디렉토리에 복사 하면 됩니다. 
아래와 같이 airflow ec2 인스턴스 로그인 하여, ps 명령어를 이용하여 airflow 가 정상적으로 동작중인지 확인힙니다.
파이썬으로 구현된 job 파일을 받아오기 위해 아래 예제에서 처럼 github repo 를 clone 한 후, ~/airflow/dags 디렉토리로 job 파일을 복사합니다. 
```
ubuntu@ip-10-1-1-93:~$ ps aux | grep airflow
ubuntu     10019  0.7  1.5 375160 116900 ?       S    10:20   0:01 /usr/bin/python3 /usr/local/bin/airflow webserver -D
ubuntu     10023  0.0  0.5  68056 42704 ?        S    10:20   0:00 gunicorn: master [airflow-webserver]
ubuntu     10024  1.6  1.4 358116 115164 ?       Sl   10:20   0:03 [ready] gunicorn: worker [airflow-webserver]
ubuntu     10025  1.7  1.4 358116 115168 ?       Sl   10:20   0:03 [ready] gunicorn: worker [airflow-webserver]
ubuntu     10026  1.7  1.4 358112 115164 ?       Sl   10:20   0:03 [ready] gunicorn: worker [airflow-webserver]
ubuntu     10027  1.6  1.4 358108 115164 ?       Sl   10:20   0:03 [ready] gunicorn: worker [airflow-webserver]
ubuntu     10077  6.5  0.9 109388 76680 ?        S    10:23   0:00 /usr/bin/python3 /usr/local/bin/airflow scheduler -D
ubuntu     10078  0.0  0.9 108620 75360 ?        S    10:23   0:00 airflow serve-logs
ubuntu     10079  0.5  0.9 109132 77032 ?        S    10:23   0:00 airflow scheduler -- DagFileProcessorManager
ubuntu     10094  0.0  0.0   8160   740 pts/0    S+   10:24   0:00 grep airflow

ubuntu@ip-10-1-1-93:~$ git clone https://github.com/gnosia93/bigdata-on-aws.git

ubuntu@ip-10-1-1-93:~$ cp bigdata-on-aws/jobs/airflow_workshop_job.py ~/airflow/dags/

ubuntu@ip-10-1-1-93:~$ airflow dags list
dag_id               | filepath                | owner   | paused
=====================+=========================+=========+=======
airflow_workshop_job | airflow_workshop_job.py | airflow | None
```

브라우저를 airflow 가 설치된 ec2 인스턴스의 8080 포트로 접속합니다. 

* http://ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com:8080


### 4. connections 설정 ###

[airflow_workshop_job](https://github.com/gnosia93/bigdata-on-aws/blob/main/jobs/airflow_workshop_job.py) 파이썬 코드에서는 postgresql 데이터베이스에 접근하기 위해서, postgres_default 라는 키워드를 사용하고 있습니다. 해당 키워드는 에어 플로우가 기본적으로 제공하는 postgresql 용 키값으로 airflow 의 connections 메뉴에서 해당 키에 대한 정보를 설정하실 수 있습니다.

```
 ctas_dummy_table = PostgresOperator(
        task_id="ctas_dummy_table",
        postgres_conn_id="postgres_default",
        sql="""
            create table tbl_airflow_dummy as 
            select 'dummy'|| right('0' || line, 2) as line, 
            repeat('Aa', 20) as comment, 
            to_char(generate_series('2021-01-01 00:00'::timestamp,'2021-06-30 12:00', '1 minutes'), 'YYYY-MM-dd hh:mi') as created
            from generate_series(1, 100) as tbl(line);
          """,
    )   
```

상단 Admin 메뉴의 Connections 팝업창 메뉴로 이동한 다음, 
![conn1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow_conn-1.png)

postgres_default 항목을 찾아 [Edit record] 버튼을 클릭합니다. 
![conn2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow_conn-2.png)

[Edit Connection] 화면에서 Host, Schema, Login, Password 및 Port 정보를 입력한 후 좌측 하든의 [Save] 버튼을 클릭하여 설정 내용을 저장합니다. 

```
Host : your-rds-endpoint
Schema : airline_db
Login : airline
Password : airline
Port : 5432
```
![conn3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow_conn-3.png)



### 5. job 실행하기 ###

airflow_workshop_job 의 좌측에 있는 회식 버튼을 토글하여 파란색으로 바꾼 다음,  

![job-start1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-1.png) 

Actions 밑에 있는 [화살표 버튼]을 클릭하여 팝업창에서 [Trigger DAG] 메뉴를 선택합니다.

![job-start2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-2.png)

잡 목록에서 airflow_workshp_job 을 클릭하여 Tree View 화면에서 작업 상태를 관찰합니다. 
![job-start3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-3.png)


## 참고자료 ##

* [우분투에 airflow 설치하기](https://jungwoon.github.io/airflow/2019/02/26/Airflow.html)

* [airflow 이해하기](https://graspthegist.com/2018/11/26/airflow-part-1-2-bash/)

* [emr spark submit rest api](https://www.python2.net/questions-274169.htm)

* [spark submit operator](https://stackoverflow.com/questions/53773678/airflow-sparksubmitoperator-how-to-spark-submit-in-another-server)
