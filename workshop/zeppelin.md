### 1. 제플린 접속하기 ###

emr 제플린에 아래와 같이 접속합니다. 


### 2. 데이터 프레임 이해하기 ###

```
$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/flight-data/json/2015-summary.json
$ hadoop fs -put 2015-summary.json /tmp/spark

$ hadoop fs -ls -R /tmp/spark
-rw-r--r--   1 soonbeom supergroup      21368 2021-07-18 17:00 /tmp/spark/2015-summary.json
```
