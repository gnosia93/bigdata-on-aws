### airflow job spec ###

* database operator - dummmy 레코드 gen (300만건)
* sqoop operator - import data into hadoop 
* spark operator - summary spark job with hdfs
  - spark job 's output destination is hdfs

* executed every 10 min.

------------
### airflow ###

-- connection 
* https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html
* https://xnuinside.medium.com/short-guide-how-to-use-postgresoperator-in-apache-airflow-ca78d35fb435

### PostgreSQL ###

* https://dullyshin.github.io/2020/03/13/PostgreSQL-generateSeries/
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html

```
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.postgres_operator import PostgresOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2019, 8, 25),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG('example_dag',
            max_active_runs=3,
            schedule_interval='@daily',
            default_args=default_args) as dag:

    t1 = PostgresOperator(
        task_id='my_task',
        sql='sql/my_query.sql'
    )


```
