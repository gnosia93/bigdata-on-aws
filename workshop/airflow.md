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

### PostgreSQL ###

```
airline_db=> create table tbl_dummy as 
select 'dummy'|| right('0' || line, 2) as line, 
       repeat('Aa', 20) as comment, 
       to_char(generate_series('2021-01-01 00:00'::timestamp,'2021-06-30 12:00', '1 minutes'), 'YYYY-MM-dd hh:mi') as created
from generate_series(1, 100) as tbl(line);

SELECT 25992100

airline_db=> select pg_total_relation_size('tbl_dummy');
 pg_total_relation_size
------------------------
             6868631552
(1 row)
```


### airflow job - postgres ###

* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
```
from airflow import DAG
from airflow.utils.dates import days_ago
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator

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

    create_pet_table = PostgresOperator(
        task_id="create_table",
        postgres_conn_id="postgres_default",
        sql="""
            CREATE TABLE IF NOT EXISTS pet (
            pet_id SERIAL PRIMARY KEY,
            name VARCHAR NOT NULL,
            pet_type VARCHAR NOT NULL,
            birth_date DATE NOT NULL,
            OWNER VARCHAR NOT NULL);
          """,
    )   
    
    populate_pet_table = PostgresOperator(
        task_id="populate_pet_table",
        postgres_conn_id="postgres_default",
        sql="""
            INSERT INTO pet VALUES ( 'Max', 'Dog', '2018-07-05', 'Jane');
            INSERT INTO pet VALUES ( 'Susie', 'Cat', '2019-05-01', 'Phil');
            INSERT INTO pet VALUES ( 'Lester', 'Hamster', '2020-06-23', 'Lily');
            INSERT INTO pet VALUES ( 'Quincy', 'Parrot', '2013-08-11', 'Anne');
            """,
    )
    
    create_pet_table >> populate_pet_table >> get_all_pets >> get_birth_date
    
if __name__ == "__main__":
    dag.cli()
```


## 참고자료 ##

* https://dullyshin.github.io/2020/03/13/PostgreSQL-generateSeries/
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html


