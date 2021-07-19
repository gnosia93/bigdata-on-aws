## airflow jobs ##

### 1. airflow 실행하기 ###

```
$ terraform output | grep airflow
airflow_public_ip = ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/.ssh/tf_key ubuntu@ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com (13.125.226.210)' can't be established.
ECDSA key fingerprint is SHA256:APd2pTzZPa7aurbP4kUvYF72GREBsDca6kOxw3EjQJA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-13-125-226-210.ap-northeast-2.compute.amazonaws.com,13.125.226.210' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1029-aws x86_64)

ubuntu@ip-10-1-1-93:~$ airflow db init

ubuntu@ip-10-1-1-93:~$ airflow webserver -D
  ____________       _____________
 ____    |__( )_________  __/__  /________      __
____  /| |_  /__  ___/_  /_ __  /_  __ \_ | /| / /
___  ___ |  / _  /   _  __/ _  / / /_/ /_ |/ |/ /
 _/_/  |_/_/  /_/    /_/    /_/  \____/____/|__/
[2021-07-19 10:20:45,859] {dagbag.py:496} INFO - Filling up the DagBag from /dev/null
[2021-07-19 10:20:45,885] {manager.py:784} WARNING - No user yet created, use flask fab command to do it.
Running the Gunicorn Server with:
Workers: 4 sync
Host: 0.0.0.0:8080
Timeout: 120
Logfiles: - -
Access Logformat:
=================================================================

ubuntu@ip-10-1-1-93:~/airflow$ airflow scheduler -D
  ____________       _____________
 ____    |__( )_________  __/__  /________      __
____  /| |_  /__  ___/_  /_ __  /_  __ \_ | /| / /
___  ___ |  / _  /   _  __/ _  / / /_/ /_ |/ |/ /
 _/_/  |_/_/  /_/    /_/    /_/  \____/____/|__/
 
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

ubuntu@ip-10-1-1-93:~/airflow$ airflow dags list
dag_id                                  | filepath                                                                                          | owner   | paused
========================================+===================================================================================================+=========+=======
example_bash_operator                   | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_bash_operator.py              | airflow | True
example_branch_datetime_operator_2      | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_branch_datetime_operator.py   | airflow | True
example_branch_dop_operator_v3          | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_branch_python_dop_operator_3. | airflow | True
                                        | py                                                                                                |         |
example_branch_labels                   | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_branch_labels.py              | airflow | True
example_branch_operator                 | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_branch_operator.py            | airflow | True
example_complex                         | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_complex.py                    | airflow | True
example_dag_decorator                   | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_dag_decorator.py              | airflow | True
example_external_task_marker_child      | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_external_task_marker_dag.py   | airflow | True
example_external_task_marker_parent     | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_external_task_marker_dag.py   | airflow | True
example_kubernetes_executor             | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_kubernetes_executor.py        | airflow | True
example_nested_branch_dag               | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_nested_branch_dag.py          | airflow | True
example_passing_params_via_test_command | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_passing_params_via_test_comma | airflow | True
                                        | nd.py                                                                                             |         |
example_python_operator                 | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_python_operator.py            | airflow | True
example_short_circuit_operator          | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_short_circuit_operator.py     | airflow | True
example_skip_dag                        | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_skip_dag.py                   | airflow | True
example_subdag_operator                 | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_subdag_operator.py            | airflow | True
example_subdag_operator.section-1       | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_subdag_operator.py            | airflow | True
example_subdag_operator.section-2       | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_subdag_operator.py            | airflow | True
example_task_group                      | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_task_group.py                 | airflow | True
example_task_group_decorator            | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_task_group_decorator.py       | airflow | True
example_trigger_controller_dag          | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_trigger_controller_dag.py     | airflow | True
example_trigger_target_dag              | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_trigger_target_dag.py         | airflow | True
example_weekday_branch_operator         | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_branch_day_of_week_operator.p | airflow | True
                                        | y                                                                                                 |         |
example_xcom                            | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_xcom.py                       | airflow | True
example_xcom_args                       | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_xcomargs.py                   | airflow | True
example_xcom_args_with_operators        | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_xcomargs.py                   | airflow | True
latest_only                             | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_latest_only.py                | airflow | True
latest_only_with_trigger                | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/example_latest_only_with_trigger.py   | airflow | True
test_utils                              | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/test_utils.py                         | airflow | True
tutorial                                | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/tutorial.py                           | airflow | True
tutorial_etl_dag                        | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/tutorial_etl_dag.py                   | airflow | True
tutorial_taskflow_api_etl               | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/tutorial_taskflow_api_etl.py          | airflow | True
tutorial_taskflow_api_etl_virtualenv    | /usr/local/lib/python3.8/dist-packages/airflow/example_dags/tutorial_taskflow_api_etl_virtualenv. | airflow | True
                                        | py                                                                                                |         |
```

### 2. airflow 웹 화면 접속 ###

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
    dag_id='workshop_job',
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





