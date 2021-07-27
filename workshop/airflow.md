![airflow](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-logo.png)

아파치 에어플로우는 작업 흐름을 관리 및 실행하는 오픈소스 엔진으로 에어비앤비에 의해 개발되었습니다. 에어플로우는 파이썬을 이용하여 동적으로 작업의 흐름을 정의할 수 있고,
각종 Operator를 이용하여 쉽게 작업 흐름을 구현할 수 있습니다. 또한 여러개의 워커노드를 이용하여 대규모의 작업 관리가 가능합니다.

### 1. airflow_workshop_job 의 이해 ###

이번 챕터에서는 [airflow_workshop_job](https://github.com/gnosia93/bigdata-on-aws/blob/main/jobs/airflow_workshop_job.py) 을 이용하여 에어플로우에 대한 실습을 진행하도록 하겠습니다.
해당 잡은 아래와 같이 4개의 오퍼레이터로 구성되며, 각각의 기능은 아래와 같습니다. 

* postgres operator - dummy 테이블 삭제(존재시)
* postgres operator - dummy 테이블 및 레코드 생성 (약 2100만건, 생성 소요시간 30초)
* bash operator - sqoop import (copy table to hdfs)
* spark submit operator - 집계처리하여 총건수를 postgresql 에 저장

![dags](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-dags.png)

```
[Known Issues]

  1. spark job은 airflow local 에서 수행 됩니다. --> emr cluster 수행으로 수정 예정 (아래 내용 참조)
    --> https://aws.amazon.com/ko/premiumsupport/knowledge-center/emr-submit-spark-job-remote-cluster/
    --> https://medium.com/@tamizhgeek/remote-spark-submit-toyarn-running-on-emr-9804b89d82d2
    --> http://dekarlab.de/wp/?p=613
    
  2. sqoop 작업 역시 airflow local 에서 수행됩니다. 
    --> sqoop 1.4 버전을 사용중이며, 1.4 는 rest api 를 지원하지 않음.
  
  3. sqoop 작업은 bashoperator를 이용하여 실행되는데, 최초 실행시에는 컴파일된 맵리듀스 jar 파일을 찾지 못해 오류가 발생합니다. (sqoop 자체의 버그인듯)
    --> 재시도시 정상적으로 동작합니다. 
    
```


### 2. 에어 플로우 마스터 노드 설정하기 ###

에어플로우 노드에서 EMR 작업을 리모트로 실행하기 위해, 하둡 및 스파크 패키지를 설치합니다.(에어 플로우 노드 생성시 자동 설치됨, https://github.com/gnosia93/bigdata-on-aws/blob/main/tf/ec2.tf 의 user_data 참조)   
리모트로 작업을 실행하기 위해서는 하둡 core-site.xml 파일에 대한 설정 역시 필요하며, 스파크의 경우 yarn-site.xml  편집해야 합니다. 
아파치 스쿱 역시 설치가 필요한데, 스쿱의 map-reduce 작업은 airflow ec2 인스턴스에서 직접 실행됩니다 (스쿱 1.4 버전을 사용하고 있고, 해당 버전은 Rest API 가 없기 때문.)

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


ubuntu@ip-10-1-1-198:~$ cp $SQOOP_HOME/conf/sqoop-env-template.sh $SQOOP_HOME/conf/sqoop-env.sh
ubuntu@ip-10-1-1-198:~$ echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> $SQOOP_HOME/conf/sqoop-env.sh
ubuntu@ip-10-1-1-198:~$ echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> $SQOOP_HOME/conf/sqoop-env.sh

ubuntu@ip-10-1-1-198:~$ hadoop fs -ls /
Found 4 items
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-20 12:17 /apps
drwxrwxrwt   - hdfs hdfsadmingroup          0 2021-07-20 16:54 /tmp
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-20 15:14 /user
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-20 12:17 /var
```
(중요) 스파크 설정은 현 버전의 워크샵에서는 생략합니다 [Known Issues 참조]


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

브라우저로 airflow 가 설치된 ec2 인스턴스의 8080 포트로 접속합니다. 

* http://ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com:8080



### 4. spark 어플리케이션 설치하기 ###

스파크 어플리케이션을 아래의 순서 대로 설치합니다. sbt 는 scala 에서 주로 사용하는 패키지 메니저로 mvn 과 같은 기능을 수행합니다. 
sbt assembly 실행시 시간이 다소 오래 소요될 수 있습니다. 
```
ubuntu@ip-10-1-1-93:~$ git clone https://github.com/gnosia93/sparkapp

ubuntu@ip-10-1-1-93:~$ cd sparkapp

ubuntu@ip-10-1-1-93:sparkapp$ vi project/assembly.sbt
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.6")

ubuntu@ip-10-1-1-93:sparkapp$ vi build.sbt
name := "sparkapp"

version := "0.1"

scalaVersion := "2.12.12"

libraryDependencies ++= Seq (
  "org.apache.spark" %% "spark-core" % "3.1.1" % "provided",         <--- % "provided" 추가 
  "org.apache.spark" %% "spark-sql" % "3.1.1" % "provided" ,         <--- % "provided" 추가 
  "org.postgresql" % "postgresql" % "42.2.23"

)

ubuntu@ip-10-1-1-93:sparkapp$ sbt assembly

ubuntu@ip-10-1-1-93:sparkapp$ ls -la target/scala-2.12/sparkapp-assembly-0.1.jar 
-rw-rw-r-- 1 ubuntu ubuntu 6638135 Jul 22 15:35 target/scala-2.12/sparkapp-assembly-0.1.jar
```


### 5. connections 설정 ###

connections 은 타켓 리소스를 억세스할 때 필요한 각종 정보를 모아 놓은 정보의 집합체 입니다. 타켓 리소스가 데이터베이스인 경우 연결관련 정보를 저장하고 있고, 스파크인 경우에는 리소스 매니저로  yarn 사용 여부를 결정하게 됩니다. 

이러한 connection 정보는 에어플로우 job 소스 코드에서 각종 오퍼레이터에 의해 참조 됩니다(아래 코드 참조)

[airflow workshop job 에서 발췌]
```
 ctas_dummy_table = PostgresOperator(
        task_id="ctas_dummy_table", 
        postgres_conn_id="postgres_default",      <----- connections
        sql="""
            create table tbl_airflow_dummy as 
            select 'dummy'|| right('0' || line, 2) as line, 
            repeat('Aa', 20) as comment, 
            to_char(generate_series('2021-01-01 00:00'::timestamp,'2021-06-30 12:00', '1 minutes'), 'YYYY-MM-dd hh:mi') as created
            from generate_series(1, 100) as tbl(line);
          """,
    )   
```

이번 실습에서는 두가지의 connection 정보 설정이 필요합니다. 

* postgres
* spark

connection 정보 설정을 위해 에어플로우 상단 Admin 메뉴의 Connections 팝업창 메뉴로 이동한 다음, 
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


동일하게 connection 리스트 화면에서 spark_default 항목을 찾아 [Edit record] 버튼을 클릭한 후, Host 값으로 yarn 을 입력합니다. 
```
Host : yarn
```
![conn4](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow_conn-4.png)


### 6. job 실행하기 ###

airflow_workshop_job 의 좌측에 있는 회색 버튼을 토글하여 파란색으로 바꾼 다음,  

![job-start1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-1.png) 

Actions 밑에 있는 [화살표 버튼]을 클릭하여 팝업창에서 [Trigger DAG] 메뉴를 선택합니다.

![job-start2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-2.png)

잡 목록에서 airflow_workshp_job 을 클릭하여 Tree View 화면에서 작업 상태를 관찰합니다. 

![job-start3-1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/airflow-job-start-3-2.png)


## 참고자료 ##

* [우분투에 airflow 설치하기](https://jungwoon.github.io/airflow/2019/02/26/Airflow.html)

* [airflow 이해하기](https://graspthegist.com/2018/11/26/airflow-part-1-2-bash/)

