# bigdata-on-aws #

본 워크샵은 빅데이터 솔루션에 대한 전반적인 이해를 돕고자, AWS 클라우드의 EMR 서비스를 이용하여, 코드 및 데이터 샘플 기반으로 작성되었습니다.
워크샵을 원활하게 진행하기 위해 파이썬, 스칼라 그리고 SQL 문법에 대한 기초적인 지식이 필요하나, 필수는 아니며, 요구 수준은 또한 높지 않습니다.
로컬 PC는 맥(mac)으로 가정하고 작성되었습니다. 

![archi](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/aws-architecture.png)

실습에 필요한 리소스는 테라폼을 이용하여 프로비저닝 하며,

- telegraf 가 설치되는 EC2, EMR 및 Airflow 노드는 실습의 편의를 위해 퍼블릭 서브넷에 배치되고,
- MSK(카프카) 와 PostgreSQL(RDS) 는 프라이빗 서브넷에 배치됩니다.
- 데이터는 주로 EMR 클러스터의 HDFS 에 저장되며, 일부 데이터는 PostgreSQL 에도 저장됩니다. 
- EMR 클러스터에 리모트 접근하기 위해 Telegraf EC2 및 Airflow 노드 에는 하둡, 스파크 바이너라가 설치됩니다. 


## 실습 ##

* [1. 리소스 생성](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/setup.md)

* [2. 하둡 및 카프카 테스트](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/hadoop-kafka.md)

* [3. 하이브 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/hive.md)

* [4. 카프카 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/kafka.md)

* [5. 스파크 스트리밍 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/spark.md) 

* [6. 스쿱 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/sqoop.md)

* [7. 제플린 노트북 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/zeppelin.md)

* [8. 에어플로우 실습](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/airflow.md)



## Revison History ##

* 2021-07-25 first released.
