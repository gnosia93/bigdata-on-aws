from airflow import DAG
from airflow.utils.dates import days_ago
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
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
    
    # 최초 실행시 sqoop 가 컴파일 된 자바 클래스 파일을 읽어오지 못하는 버그가 있어서 첫번째 실행시는 작업이 실패한다. 
    # 두번째 실행부터는 이미 bindir 에 컴파일된 클래스 파일이 있기 때문에 정상 동작한다. 
    cmd = """
        . ~/.bash_profile &&
        HADOOP_USER_NAME=hdfs sqoop import \
           --connect jdbc:postgresql://bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432/airline_db \
           --username airline \
           --password airline \
           --table tbl_airflow_dummy \
           --target-dir hdfs://ec2-13-125-199-100.ap-northeast-2.compute.amazonaws.com:8020/tmp/airflow \
           --bindir $SQOOP_HOME/lib \
           -m 1 \
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

 
    # https://airflow.apache.org/docs/apache-airflow/1.10.12/_api/airflow/contrib/operators/spark_submit_operator/index.html
    spark_file_counter = SparkSubmitOperator(
        task_id='spark_file_counter', 
        dag=dag, 
        conn_id="spark_default",
        application="/home/ubuntu/sparkapp/target/scala-2.12/sparkapp-assembly-0.1.jar",
        driver_memory="1g",
        executor_cores= 1,
        executor_memory= "1g",
        num_executors=4,
        driver_class_path="/home/ubuntu/.ivy2/cache/org.postgresql/postgresql/jars/postgresql-42.2.23.jar",
        jars="/home/ubuntu/.ivy2/cache/org.postgresql/postgresql/jars/postgresql-42.2.23.jar",
        application_args = [
            "hdfs://ec2-13-125-199-100.ap-northeast-2.compute.amazonaws.com:8020/tmp/airflow/",
            "jdbc:postgresql://bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432/airline_db" 
        ],

    )
    

    
    drop_dummy_table >> ctas_dummy_table >> sqoop_import_dummy_table >> spark_file_counter
