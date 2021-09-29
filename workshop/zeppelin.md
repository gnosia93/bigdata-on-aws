![logo](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin_logo.png)

Apache Zeppelin은 Spark 쉘을 통한 데이터 분석의 불편함을 Web기반의 Notebook 환경을 통해 해결해보고자 만들어진 어플리케이션으로, 
코드를 작성, 실행, 결과확인, 코드수정 과정을 반복하면서 원하는 결과를 만들어 낼수있는 작업 환경을 제공합니다.

Zeppelin 에 대한 좀더 자세한 내용은 아래 링크를 참조하세요.

* [Apache Zeppelin 이란 무엇인가?](https://medium.com/apache-zeppelin-stories/%EC%98%A4%ED%94%88%EC%86%8C%EC%8A%A4-%EC%9D%BC%EA%B8%B0-2-apache-zeppelin-%EC%9D%B4%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80-f3a520297938)


### 1. hdfs에 데이터 로딩하기 ###

테라폼을 이용하여 엔드포인트를 조회한 후, 아래와 같이 ec2 인스턴스에 로그인 합니다. 제플린 노트북에서 사용할 샘플 데이터를 다운로드 받은 후, emr 하둡에 저장합니다. 

* https://github.com/databricks/Spark-The-Definitive-Guide
```
$ terraform output 

airflow_public_ip = "ec2-52-79-178-219.ap-northeast-2.compute.amazonaws.com"
ec2_public_ip = "ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com"
emr_master_public_dns = "ec2-3-36-96-133.ap-northeast-2.compute.amazonaws.com"
msk_brokers = "b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092"
rds_endpoint = "bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432"


$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/

[ec2-user@ip-10-1-1-31 ~]$ mkdir -p data/zeppelin
[ec2-user@ip-10-1-1-31 ~]$ cd data/zeppelin

[ec2-user@ip-10-1-1-31 zeppelin]$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/flight-data/json/2015-summary.json
[ec2-user@ip-10-1-1-31 zeppelin]$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/retail-data/all/online-retail-dataset.csv

[ec2-user@ip-10-1-1-31 zeppelin]$ hadoop fs -mkdir -p /tmp/spark
[ec2-user@ip-10-1-1-31 zeppelin]$ hadoop fs -put 2015-summary.json /tmp/spark
[ec2-user@ip-10-1-1-31 zeppelin]$ hadoop fs -put online-retail-dataset.csv /tmp/spark

[ec2-user@ip-10-1-1-31 zeppelin]$ hadoop fs -ls -R /tmp/spark
-rw-r--r--   1 soonbeom supergroup      21368 2021-07-18 17:00 /tmp/spark/2015-summary.json
-rw-r--r--   1 soonbeom supergroup   45038760 2021-07-18 17:58 /tmp/spark/online-retail-dataset.csv
```

### 2. 제플린 인터프리터 설정 ###

AWS emr 콘솔에서 제플린 주소 확인 후(클러스터 목록 > 애플리케이션 이력), 브라우저로 제플린 노트북에 접속합니다. 

![emr-app-url](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/emr-app-url.png)

제플린 노트북을 out of memory 오류 없이 실행하기 위해서는 몇가지 인터프리터 설정을 변경해야 합니다.   
제플린 화면에서 우측 상단의 anonymous 버튼을 클릭한 후, Interpreter 메뉴를 선택하도록 합니다.

![int1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-interpreter-1.png)

검색창에 spark 를 입력하고 우측에 있는 [edit] 버튼을 클릭합니다. 
![int2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-interpreter-2.png)

아래의 내용 각각을 화면에서 보이는 처럼 추가하고, 하단의 [save] 버튼을 클릭하여 설정을 저장합니다. 
```
spark.dynamicAllocation.enabled = true
spark.shuffle.service.enabled = true
spark.executor.memory = 1g
```
![int3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-interpreter-3.png)

상단 메뉴의 [Notebook] 을 클릭한 후 나타나는 팝업 메뉴에서 [+Create new note]를 선택한 후, Create New Note 팝업창이 나오면, Note Name 필드값으로 spark-job 으로 입력하고 [Create] 버튼을 클릭합니다.

%spark, %pyspark, %sql 인터프리터를 테스트 합니다. %spark은 스칼러 코드를 해석 및 실행하는 기본 인터프리터로 명시적으로 선언하지 않으면 %spark 인터프리터가 실행됩니다. %pyspark 은 제플린 노트북에서 파이썬을 사용하고자 할때 사용하는 인터프리터 이며, %sql 은 SQL 인터프리터 입니다. SQL 만을 이용하여 데이터에 대한 조회 및 오퍼레이션을 수행할 수 있습니다.

![int4](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-interpreter-4.png)


### 3. 제플린 노트북 생성 ###

제플린 콘솔에서 아래 그림 처럼 새로운 노트북을 생성합니다. 

![note1](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-create-note1.png)

![note2](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-create-note2.png)



### 4. 데이터 프레임 샘플 테스트 하기 ###

제플린 노트북은 다양항 형태의 인터프러터를 지원하나 이번 챕터에서는 %spark 인터프리터를 이용하여 스파크 데이터 프레임을 테스트해 보겟습니다. 
데이터 프레임은 스파크가 제공하는 구조적인 API 로서, 로우와 칼럼 형태의 DB 테이블 처럼 데이터를 쉽고 빠르게 조작하는 것을 가능하게 하는 스파크 객체입니다. 데이터 프레임은 데이터에 대한 조회, 필터링 및 집계 기능을 제공합니다. 

아래 그림은 제플린 노트북 실행 화면을 캡처한 것으로 spark-shell 과는 달리 웹UI 형태의 인터페이스를 제공하고 있어, 손쉬운 데이터 조회와 분석이 가능합니다.
셀단위로 스파크 어플리케이션 코딩이 가능하며, [shift] + [Enter] 키로 해당 셀을 실행하거나, 셀 우측 상단의 실행버튼을 클릭하면 해당 셀의 코드를 실행할 수 있습니다.  

![note3](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/zeppelin-notebook.png)

아래 hdfs URL은 여러분들의 EMR 마스터 주소로 바꾼 후, 아래 샘플 코드를 제플린 노트북에서 실행하고, 그 결과를 확인 하도록 합니다. 

[샘플 코드]
```
// 하둡에서 json 파일을읽어 데이터프레임으로 변환
val df = spark.read.format("json")
    .load("hdfs://ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com:8020/tmp/spark/2015-summary.json")         // hdfs URL을 emr 마스터 주소로 바꾸세요.

println("rows :" + df.count())    
df.show(10)    

// 스키마 출력
df.printSchema()

// 데이터 출력
df.select("ORIGIN_COUNTRY_NAME").show(3)
df.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME").show(1)

// 다양한 칼럼 참조 방법
df.select(
    df.col("ORIGIN_COUNTRY_NAME"),
    col("ORIGIN_COUNTRY_NAME"),  
    column("ORIGIN_COUNTRY_NAME"),
    'ORIGIN_COUNTRY_NAME,
    $"ORIGIN_COUNTRY_NAME",
    expr("ORIGIN_COUNTRY_NAME")
).show(2)

// 칼럼명 변경 및 drop 하기 
df.withColumn("destination", $"DEST_COUNTRY_NAME")
    .withColumn("origin", $"ORIGIN_COUNTRY_NAME") 
    .withColumnRenamed("count", "cnt")
    .drop("DEST_COUNTRY_NAME").show()
```

[결과]
```
rows :256
+-----------------+-------------------+-----+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+-----------------+-------------------+-----+
|    United States|            Romania|   15|
|    United States|            Croatia|    1|
|    United States|            Ireland|  344|
|            Egypt|      United States|   15|
|    United States|              India|   62|
|    United States|          Singapore|    1|
|    United States|            Grenada|   62|
|       Costa Rica|      United States|  588|
|          Senegal|      United States|   40|
|          Moldova|      United States|    1|
+-----------------+-------------------+-----+
only showing top 10 rows

root
 |-- DEST_COUNTRY_NAME: string (nullable = true)
 |-- ORIGIN_COUNTRY_NAME: string (nullable = true)
 |-- count: long (nullable = true)

+-------------------+
|ORIGIN_COUNTRY_NAME|
+-------------------+
|            Romania|
|            Croatia|
|            Ireland|
+-------------------+
only showing top 3 rows

+-----------------+-------------------+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|
+-----------------+-------------------+
|    United States|            Romania|
+-----------------+-------------------+
only showing top 1 row

+-------------------+-------------------+-------------------+-------------------+-------------------+-------------------+
|ORIGIN_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|
+-------------------+-------------------+-------------------+-------------------+-------------------+-------------------+
|            Romania|            Romania|            Romania|            Romania|            Romania|            Romania|
|            Croatia|            Croatia|            Croatia|            Croatia|            Croatia|            Croatia|
+-------------------+-------------------+-------------------+-------------------+-------------------+-------------------+
only showing top 2 rows

+-------------------+---+--------------------+----------------+
|ORIGIN_COUNTRY_NAME|cnt|         destination|          origin|
+-------------------+---+--------------------+----------------+
|            Romania| 15|       United States|         Romania|
|            Croatia|  1|       United States|         Croatia|
|            Ireland|344|       United States|         Ireland|
|      United States| 15|               Egypt|   United States|
|              India| 62|       United States|           India|
|          Singapore|  1|       United States|       Singapore|
|            Grenada| 62|       United States|         Grenada|
|      United States|588|          Costa Rica|   United States|
|      United States| 40|             Senegal|   United States|
|      United States|  1|             Moldova|   United States|
|       Sint Maarten|325|       United States|    Sint Maarten|
|   Marshall Islands| 39|       United States|Marshall Islands|
|      United States| 64|              Guyana|   United States|
|      United States|  1|               Malta|   United States|
|      United States| 41|            Anguilla|   United States|
|      United States| 30|             Bolivia|   United States|
|           Paraguay|  6|       United States|        Paraguay|
|      United States|  4|             Algeria|   United States|
|      United States|230|Turks and Caicos ...|   United States|
|          Gibraltar|  1|       United States|       Gibraltar|
+-------------------+---+--------------------+----------------+
only showing top 20 rows

df: org.apache.spark.sql.DataFrame = [DEST_COUNTRY_NAME: string, ORIGIN_COUNTRY_NAME: string ... 1 more field]
```

### 5. 데이터 프레임 필터링 하기 ###

[샘플 코드]
```
// 필터링 하기
df.filter($"count" < 2).show(3)
df.where("count = 2").show(3)

// distinct 계산하기
df.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME").distinct().count()

// 정렬하기
df.sort("count").show(5)
df.orderBy("count", "DEST_COUNTRY_NAME").show(5)
df.orderBy(desc("count"), asc("DEST_COUNTRY_NAME")).show(5)

// 로우 제한하기
df.limit(3).show()
```

[결과]
```
+-----------------+-------------------+-----+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+-----------------+-------------------+-----+
|    United States|            Croatia|    1|
|    United States|          Singapore|    1|
|          Moldova|      United States|    1|
+-----------------+-------------------+-----+
only showing top 3 rows

+-----------------+-------------------+-----+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+-----------------+-------------------+-----+
|          Liberia|      United States|    2|
|          Hungary|      United States|    2|
|    United States|            Vietnam|    2|
+-----------------+-------------------+-----+
only showing top 3 rows

+--------------------+-------------------+-----+
|   DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+--------------------+-------------------+-----+
|               Malta|      United States|    1|
|Saint Vincent and...|      United States|    1|
|       United States|            Croatia|    1|
|       United States|          Gibraltar|    1|
|       United States|          Singapore|    1|
+--------------------+-------------------+-----+
only showing top 5 rows

+-----------------+-------------------+-----+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+-----------------+-------------------+-----+
|     Burkina Faso|      United States|    1|
|    Cote d'Ivoire|      United States|    1|
|           Cyprus|      United States|    1|
|         Djibouti|      United States|    1|
|        Indonesia|      United States|    1|
+-----------------+-------------------+-----+
only showing top 5 rows

+-----------------+-------------------+------+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME| count|
+-----------------+-------------------+------+
|    United States|      United States|370002|
|    United States|             Canada|  8483|
|           Canada|      United States|  8399|
|    United States|             Mexico|  7187|
|           Mexico|      United States|  7140|
+-----------------+-------------------+------+
only showing top 5 rows

+-----------------+-------------------+-----+
|DEST_COUNTRY_NAME|ORIGIN_COUNTRY_NAME|count|
+-----------------+-------------------+-----+
|    United States|            Romania|   15|
|    United States|            Croatia|    1|
|    United States|            Ireland|  344|
+-----------------+-------------------+-----+
```

### 6. 데이터 프레임 집계와 그룹핑 ###

[샘플 코드]
```
val df = spark.read.format("csv")
    .option("header", "true")
    .option("inferSchema", "true")    // 스키마 추론
    .load("hdfs://ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com:8020/tmp/spark/online-retail-dataset.csv")          // hdfs URL을 emr 마스터 주소로 바꾸세요.

df.show()    
println("rows: " + df.count())
df.printSchema()

// unique 한 StockCode 갯수 계산
df.select(countDistinct("StockCode")).show()

// min / max / sum / avg
df.select(min("Quantity"), max("Quantity"), sum("Quantity"), avg("Quantity")).show()
    
// 그룹핑
df.groupBy("InvoiceNo")
  .agg(count("Quantity").alias("quan"), expr("count(Quantity)"))
  .show() 
```

[결과]
```
+---------+---------+--------------------+--------+--------------+---------+----------+--------------+
|InvoiceNo|StockCode|         Description|Quantity|   InvoiceDate|UnitPrice|CustomerID|       Country|
+---------+---------+--------------------+--------+--------------+---------+----------+--------------+
|   536365|   85123A|WHITE HANGING HEA...|       6|12/1/2010 8:26|     2.55|     17850|United Kingdom|
|   536365|    71053| WHITE METAL LANTERN|       6|12/1/2010 8:26|     3.39|     17850|United Kingdom|
|   536365|   84406B|CREAM CUPID HEART...|       8|12/1/2010 8:26|     2.75|     17850|United Kingdom|
|   536365|   84029G|KNITTED UNION FLA...|       6|12/1/2010 8:26|     3.39|     17850|United Kingdom|
|   536365|   84029E|RED WOOLLY HOTTIE...|       6|12/1/2010 8:26|     3.39|     17850|United Kingdom|
|   536365|    22752|SET 7 BABUSHKA NE...|       2|12/1/2010 8:26|     7.65|     17850|United Kingdom|
|   536365|    21730|GLASS STAR FROSTE...|       6|12/1/2010 8:26|     4.25|     17850|United Kingdom|
|   536366|    22633|HAND WARMER UNION...|       6|12/1/2010 8:28|     1.85|     17850|United Kingdom|
|   536366|    22632|HAND WARMER RED P...|       6|12/1/2010 8:28|     1.85|     17850|United Kingdom|
|   536367|    84879|ASSORTED COLOUR B...|      32|12/1/2010 8:34|     1.69|     13047|United Kingdom|
|   536367|    22745|POPPY'S PLAYHOUSE...|       6|12/1/2010 8:34|      2.1|     13047|United Kingdom|
|   536367|    22748|POPPY'S PLAYHOUSE...|       6|12/1/2010 8:34|      2.1|     13047|United Kingdom|
|   536367|    22749|FELTCRAFT PRINCES...|       8|12/1/2010 8:34|     3.75|     13047|United Kingdom|
|   536367|    22310|IVORY KNITTED MUG...|       6|12/1/2010 8:34|     1.65|     13047|United Kingdom|
|   536367|    84969|BOX OF 6 ASSORTED...|       6|12/1/2010 8:34|     4.25|     13047|United Kingdom|
|   536367|    22623|BOX OF VINTAGE JI...|       3|12/1/2010 8:34|     4.95|     13047|United Kingdom|
|   536367|    22622|BOX OF VINTAGE AL...|       2|12/1/2010 8:34|     9.95|     13047|United Kingdom|
|   536367|    21754|HOME BUILDING BLO...|       3|12/1/2010 8:34|     5.95|     13047|United Kingdom|
|   536367|    21755|LOVE BUILDING BLO...|       3|12/1/2010 8:34|     5.95|     13047|United Kingdom|
|   536367|    21777|RECIPE BOX WITH M...|       4|12/1/2010 8:34|     7.95|     13047|United Kingdom|
+---------+---------+--------------------+--------+--------------+---------+----------+--------------+
only showing top 20 rows

rows: 541909
root
 |-- InvoiceNo: string (nullable = true)
 |-- StockCode: string (nullable = true)
 |-- Description: string (nullable = true)
 |-- Quantity: integer (nullable = true)
 |-- InvoiceDate: string (nullable = true)
 |-- UnitPrice: double (nullable = true)
 |-- CustomerID: integer (nullable = true)
 |-- Country: string (nullable = true)

+-------------------------+
|count(DISTINCT StockCode)|
+-------------------------+
|                     4070|
+-------------------------+

+-------------+-------------+-------------+----------------+
|min(Quantity)|max(Quantity)|sum(Quantity)|   avg(Quantity)|
+-------------+-------------+-------------+----------------+
|       -80995|        80995|      5176450|9.55224954743324|
+-------------+-------------+-------------+----------------+

+---------+----+---------------+
|InvoiceNo|quan|count(Quantity)|
+---------+----+---------------+
|   545583|  16|             16|
|  C546174|   1|              1|
|   547122|  16|             16|
|   547557|   1|              1|
|   548542|   8|              8|
|   548998|   1|              1|
|   549160|   1|              1|
|  C549913|   1|              1|
|   550469|  31|             31|
|   550617|  21|             21|
|  C550672|   1|              1|
|   550831|  10|             10|
|   551990|   1|              1|
|   552172|   1|              1|
|   552191|   6|              6|
|   552215|   1|              1|
|   552238|   3|              3|
|   552277|  66|             66|
|   552677|  58|             58|
|   552852|  62|             62|
+---------+----+---------------+
only showing top 20 rows

df: org.apache.spark.sql.DataFrame = [InvoiceNo: string, StockCode: string ... 6 more fields]
```

### 7. 스파크 SQL ###

스파크 SQL 을 이용하면 데이터 프레임의 함수를 직접 핸들링 하는 것보다 쉽게 데이터에 대한 분석 작업을 진행할 수 있습니다. spark.sql 함수를 이용하여 쿼리를 수행하기 이전에 아래의 예제처럼 createOrReplaceTempView 함수를 이용하여 뷰를 먼저 생성해야 합니다.  

[샘플 코드]
```
// 2015_summary 뷰 생성
val df = spark.read.format("json")
    .load("hdfs://ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com:8020/tmp/spark/2015-summary.json")               // hdfs URL을 emr 마스터 주소로 바꾸세요.
    .createOrReplaceTempView("2015_summary")
    
// 쿼리 실행    
spark.sql("""
    select dest_country_name, sum(count)
    from 2015_summary
    where dest_country_name like 'S%'
    group by dest_country_name
""").show(5)

// 뷰 삭제
spark.catalog.dropTempView("2015_summary")
```

[결과]
```
+-----------------+----------+
|dest_country_name|sum(count)|
+-----------------+----------+
|          Senegal|        40|
|           Sweden|       118|
|        Singapore|         3|
|         Suriname|         1|
|            Spain|       420|
+-----------------+----------+
only showing top 5 rows

df: Unit = ()
res132: Boolean = true
```


## 참고 자료 ##

* [데이터 프레임 예제 노트북](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/notebook/spark-df.zpln)
* [스파크 SQL 예제 노트북](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/notebook/spark-sql.zpln)
* [스파크 스트리밍 예제 노트북](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/notebook/spark-streaming.zpln)
* [Getting Started with Apache Zeppelin on Amazon EMR](https://garystafford.medium.com/getting-started-with-apache-zeppelin-on-amazon-emr-using-aws-glue-rds-and-s3-d5a7f3f8eeaa)
