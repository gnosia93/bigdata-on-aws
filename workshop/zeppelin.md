### 1. 제플린 접속하기 ###

emr 제플린에 아래와 같이 접속합니다. 


### 2. hdfs에 데이터 로딩하기 ###

* https://github.com/databricks/Spark-The-Definitive-Guide
```
$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/flight-data/json/2015-summary.json
$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/retail-data/all/online-retail-dataset.csv

$ hadoop fs -put 2015-summary.json /tmp/spark
$ hadoop fs -put online-retail-dataset.csv /tmp/spark

$ hadoop fs -ls -R /tmp/spark
-rw-r--r--   1 soonbeom supergroup      21368 2021-07-18 17:00 /tmp/spark/2015-summary.json
-rw-r--r--   1 soonbeom supergroup   45038760 2021-07-18 17:58 /tmp/spark/online-retail-dataset.csv
```


### 3. 데이터 프레임의 이해 ###

spark 에서 데이터 프레임은 구조적인 API 중 하나로, DB의 테이블과 같이 row 와 column 을 가지고 있는 객체로서 데이터에 대한 조회, 처리 및 집계 기능을 제공합니다. 아래 spark 데이터 프레임 코드를 제플린 노트북에서 실행하고, 결과를 확인 합니다. 

[코드]
```
// 하둡에서 json 파일을읽어 데이터프레임으로 변환
val df = spark.read.format("json")
    .load("hdfs://localhost:9000/tmp/spark/2015-summary.json")

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

### 4. 데이터 프레임 필터링 하기 ###

[코드]
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

### 5. 데이터 프레임 집계와 그룹핑 ###

[코드]
```
val df = spark.read.format("csv")
    .option("header", "true")
    .option("inferSchema", "true")    // 스키마 추론
    .load("hdfs://localhost:9000/tmp/spark/online-retail-dataset.csv")

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

### 6. 스파크 SQL ###




## 참고 ##

* [제플린 데이터 프레임 노트북](* https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/notebook/spark-df.zpln)
