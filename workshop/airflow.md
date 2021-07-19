```
$ sudo yum install python3 -y
$ pip install apache-airflow
$ airflow db init
$ airflow version
2.1.2
$ airflow info

```


## airflow jobs ##

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
    dag_id='example_bash_operator',
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
    
if __name__ == "__main__":
    dag.cli()
```

* conda 인 경우는 conda 로 install 해야 한다. 
```
$ cd $AIRFLOW_HOME/dags
$ sudo pip install apache-airflow-providers-postgres
$ conda install -c conda-forge apache-airflow-providers-postgres
```



### airflow job spec ###

* database operator - dummmy 레코드 gen (300만건)
* sqoop operator - import data into hadoop 
* spark operator - summary spark job with hdfs
  - spark job 's output destination is hdfs

* executed every 10 min.

------------


-- connection 
* https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html
* https://xnuinside.medium.com/short-guide-how-to-use-postgresoperator-in-apache-airflow-ca78d35fb435




## 참고자료 ##

* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html


