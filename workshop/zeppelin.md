### 1. 제플린 접속하기 ###

emr 제플린에 아래와 같이 접속합니다. 


### 2. hdfs에 데이터 로딩하기 ###

```
$ wget https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/master/data/flight-data/json/2015-summary.json
$ hadoop fs -put 2015-summary.json /tmp/spark

$ hadoop fs -ls -R /tmp/spark
-rw-r--r--   1 soonbeom supergroup      21368 2021-07-18 17:00 /tmp/spark/2015-summary.json
```


### 3. 데이터 프레임의 이해 ###

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
