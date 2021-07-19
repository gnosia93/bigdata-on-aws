## airflow jobs ##

### 1. 잡 등록하기 ###

```
$ terraform output | grep airflow
airflow_public_ip = ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/.ssh/tf_key ubuntu@ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com (13.125.226.210)' can't be established.
ECDSA key fingerprint is SHA256:APd2pTzZPa7aurbP4kUvYF72GREBsDca6kOxw3EjQJA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com,13.125.226.210' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1029-aws x86_64)

ubuntu@ip-10-1-1-93:~/airflow$ ps aux | grep airflow
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

```

### 2. airflow 접속 ###

브라우저를 airflow 가 설치된 ec2 인스턴스의 8080 포트로 접속합니다. 

* http://ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com:8080


### 1. postgres job ###

* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
```
from airflow import DAG
from airflow.utils.dates import days_ago
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2019, 8, 25),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='airflow_workshop_job',
    default_args=args,
    schedule_interval='@daily',
    start_date=days_ago(1),
    dagrun_timeout=timedelta(minutes=60),
    tags=['postgres', 'sqoop', 'spark'],
    params={"example_key": "example_value"},
) as dag:

    ctas_dummy_table = PostgresOperator(
        task_id="ctas_dummy_table",
        postgres_conn_id="postgres_default",
        sql="""
            create table tbl_dummy as 
            select 'dummy'|| right('0' || line, 2) as line, 
            repeat('Aa', 20) as comment, 
            to_char(generate_series('2021-01-01 00:00'::timestamp,'2021-06-30 12:00', '1 minutes'), 'YYYY-MM-dd hh:mi') as created
            from generate_series(1, 100) as tbl(line);
          """,
    )   
    
    drop_dummy_table = PostgresOperator(
        task_id="drop_dummy_table",
        postgres_conn_id="postgres_default",
        sql="""
            drop table if exists tbl_dummy;
            """,
    )
    
    drop_dummy_table >> ctas_dummy_table    
```




### airflow job spec ###

* database operator - dummmy 레코드 gen (300만건)
* sqoop operator - import data into hadoop 
* spark operator - summary spark job with hdfs
  - spark job 's output destination is hdfs

* executed every 10 min.


## 참고자료 ##

* [우분투에 airflow 설치하기](https://jungwoon.github.io/airflow/2019/02/26/Airflow.html)





