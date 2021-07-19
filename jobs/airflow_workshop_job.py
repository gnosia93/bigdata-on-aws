from airflow import DAG
from airflow.utils.dates import days_ago
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
import os

args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2021, 7, 1),
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
            create table tbl_airflow_dummy as 
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
            drop table if exists tbl_airflow_dummy;
            """,
    )
    
    cmd = """
        HADOOP_USER_NAME=hdfs sqoop import \
           --connect jdbc:postgresql://bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432/airline_db \
           --username airline \
           --password airline \
           --table tbl_airflow_dummy \
           --target-dir hdfs://ec2-13-125-218-93.ap-northeast-2.compute.amazonaws.com:8020/tmp/airflow \
           --bindir . \
           --split-by line -m 4 \
           --append
        """
    sqoop_import_dummy_table = BashOperator(
        task_id='sqoop_import_dummy_table', 
        bash_command=cmd, 
        dag=dag, 
        env={
            'CUSTOM_ENV': 'CUSTOM_VALUE',
            **os.environ
        }
    )
    
    drop_dummy_table >> ctas_dummy_table >> sqoop_import_dummy_table
