### airflow job spec ###

* database operator - dummmy 레코드 gen (300만건)
* sqoop operator - import data into hadoop 
* spark operator - summary spark job with hdfs
  - spark job 's output destination is hdfs

* executed every 10 min.

------------

### PostgreSQL ###

* https://dullyshin.github.io/2020/03/13/PostgreSQL-generateSeries/
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/operators/postgres_operator_howto_guide.html
* https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html
