![spark-streaming](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/spark-streaming1.png)
이번 챕터에서는 스파크 스트리밍 API 를 이용하여, 카프카로 전송된 EC2 의 CPU 정보를 실시간으로 읽고, 처리해 보도록 하겠습니다. 

### 1. 스파크 쉘 실행하기 ###

emr 마스터 노드로 로그인 한 후, package 옵션으로 kafka 패키지를 설정하여 스파크쉘을 실행합니다. 실행시 스파크쉘은 카프카 패키지를 자동으로 다운로드 받습니다.
executor-memory 파라미터 값은 1G 로 설정하여 실행한다. 파리니터를 설정하지 않으면 JVM 메모리 오류가 발생한다. 
```
$ terraform output 
Outputs:

ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
emr_master_public_dns = ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com
msk_brokers = b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
rds_endpoint = bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432

$ ssh -i ~/.ssh/tf_key hadoop@ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com
The authenticity of host 'ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com (3.34.196.21)' can't be established.
ECDSA key fingerprint is SHA256:IiVTTs4lnxFzQHBPIBgCErqNLmQrE/oKUJSAbJTA+AM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ec2-3-34-196-21.ap-northeast-2.compute.amazonaws.com,3.34.196.21' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
62 package(s) needed for security, out of 103 available
Run "sudo yum update" to apply all updates.

EEEEEEEEEEEEEEEEEEEE MMMMMMMM           MMMMMMMM RRRRRRRRRRRRRRR
E::::::::::::::::::E M:::::::M         M:::::::M R::::::::::::::R
EE:::::EEEEEEEEE:::E M::::::::M       M::::::::M R:::::RRRRRR:::::R
  E::::E       EEEEE M:::::::::M     M:::::::::M RR::::R      R::::R
  E::::E             M::::::M:::M   M:::M::::::M   R:::R      R::::R
  E:::::EEEEEEEEEE   M:::::M M:::M M:::M M:::::M   R:::RRRRRR:::::R
  E::::::::::::::E   M:::::M  M:::M:::M  M:::::M   R:::::::::::RR
  E:::::EEEEEEEEEE   M:::::M   M:::::M   M:::::M   R:::RRRRRR::::R
  E::::E             M:::::M    M:::M    M:::::M   R:::R      R::::R
  E::::E       EEEEE M:::::M     MMM     M:::::M   R:::R      R::::R
EE:::::EEEEEEEE::::E M:::::M             M:::::M   R:::R      R::::R
E::::::::::::::::::E M:::::M             M:::::M RR::::R      R::::R
EEEEEEEEEEEEEEEEEEEE MMMMMMM             MMMMMMM RRRRRRR      RRRRRR

[hadoop@ip-10-1-1-99 ~]$ 

[hadoop@ip-10-1-1-99 ~]$ spark-shell --master yarn --executor-memory 1G --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.1
:: loading settings :: url = jar:file:/usr/lib/spark/jars/ivy-2.4.0.jar!/org/apache/ivy/core/settings/ivysettings.xml
Ivy Default Cache set to: /home/hadoop/.ivy2/cache
The jars for the packages stored in: /home/hadoop/.ivy2/jars
org.apache.spark#spark-sql-kafka-0-10_2.12 added as a dependency
:: resolving dependencies :: org.apache.spark#spark-submit-parent-a12e58f4-40e5-4b50-bacb-1d94c181e978;1.0
	confs: [default]
	found org.apache.spark#spark-sql-kafka-0-10_2.12;3.1.1 in central
	found org.apache.spark#spark-token-provider-kafka-0-10_2.12;3.1.1 in central
	found org.apache.kafka#kafka-clients;2.6.0 in central
	found com.github.luben#zstd-jni;1.4.8-1 in central
	found org.lz4#lz4-java;1.7.1 in central
	found org.xerial.snappy#snappy-java;1.1.8.2 in central
	found org.slf4j#slf4j-api;1.7.30 in central
	found org.spark-project.spark#unused;1.0.0 in central
	found org.apache.commons#commons-pool2;2.6.2 in central
:: resolution report :: resolve 378ms :: artifacts dl 10ms
	:: modules in use:
	com.github.luben#zstd-jni;1.4.8-1 from central in [default]
	org.apache.commons#commons-pool2;2.6.2 from central in [default]
	org.apache.kafka#kafka-clients;2.6.0 from central in [default]
	org.apache.spark#spark-sql-kafka-0-10_2.12;3.1.1 from central in [default]
	org.apache.spark#spark-token-provider-kafka-0-10_2.12;3.1.1 from central in [default]
	org.lz4#lz4-java;1.7.1 from central in [default]
	org.slf4j#slf4j-api;1.7.30 from central in [default]
	org.spark-project.spark#unused;1.0.0 from central in [default]
	org.xerial.snappy#snappy-java;1.1.8.2 from central in [default]
	---------------------------------------------------------------------
	|                  |            modules            ||   artifacts   |
	|       conf       | number| search|dwnlded|evicted|| number|dwnlded|
	---------------------------------------------------------------------
	|      default     |   9   |   0   |   0   |   0   ||   9   |   0   |
	---------------------------------------------------------------------
:: retrieving :: org.apache.spark#spark-submit-parent-a12e58f4-40e5-4b50-bacb-1d94c181e978
	confs: [default]
	0 artifacts copied, 9 already retrieved (0kB/10ms)
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
21/07/18 03:10:07 WARN Client: Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
Spark context Web UI available at http://ip-10-1-1-99.ap-northeast-2.compute.internal:4040
Spark context available as 'sc' (master = yarn, app id = application_1626574200222_0005).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.1.1-amzn-0
      /_/

Using Scala version 2.12.10 (OpenJDK 64-Bit Server VM, Java 1.8.0_282)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
```

* [MVN dependancy](https://mvnrepository.com/artifact/org.apache.spark/spark-sql-kafka-0-10_2.12/3.1.1)

* [익스큐터 메모리 설정](https://stackoverflow.com/questions/22972358/change-executor-memory-and-other-configs-for-spark-shell)


### 2. 배치처리 ###

배치처리는 시작과 끝이 있는 데이터를 대상으로 어떠한 연산을 수행하는 것을 의미합니다. 이번 실습에서는 카프카에 저장된 데이터를 첫번째 옵셋 부터
마지막 옵셋까지 한꺼번에 읽어 콘솔상에 출력해 보도록 하겠습니다. 마지막 옵셋은 스파크의 데이터프레임 API 를 호출하는 시점을 의미하고, 호출 이후에 추가적으로 카프카에 적재되는 데이터에 대해서는 출력되지 않습니다. 신규 데이터에 대해서도 지속적으로 데이터를 출력하고자 하는 경우 스트리밍 API 를 이용해야 합니다.  

스파크 쉘에서 multi line 을 코딩하기 위해서는 내장명령어인 :paste 사용해야 합니다. :paste 실행 후, 아래 소스 코드를 붙여넣고 Ctrl+D 를 입력하도록 합니다.
아래 option 함수의 파리미터 중 kafka.bootstrap.servers 의 값은 여러분들의 카프카 브로커 주소로 변경해야 합니다. 
```
scala> :paste
scala> val kdf = spark.read.format("kafka") 
                     .option("kafka.bootstrap.servers", "b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092")     // 브로커를 여려분들의 카프카 브로커 주소로 변경하세요.
                     .option("subscribe", "cpu-metric") 
                     .option("startingOffsets", "earliest") 
                     .load()  // kdf 는 카프카 데이터 프레임입니다. 

scala> kdf
res0: org.apache.spark.sql.DataFrame = [key: binary, value: binary ... 5 more fields]

scala> kdf.printSchema()
root
 |-- key: binary (nullable = true)
 |-- value: binary (nullable = true)
 |-- topic: string (nullable = true)
 |-- partition: integer (nullable = true)
 |-- offset: long (nullable = true)
 |-- timestamp: timestamp (nullable = true)
 |-- timestampType: integer (nullable = true)

scala> kdf.count()			// 스파크 액션으로, 데이터 프레임의 레코드 수를 카운트 합니다. 
res2: Long = 23112

scala> kdf.sort(desc("timestamp")).show(5)       // timestamp 의 역순으로 메시지를 출력합니다. show()로 호출하는 경우 20건 표시됩니다.  
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|[63 70 75 2C 63 7...|cpu-metric|        0| 23149|2021-07-18 03:17:57|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0| 23148|2021-07-18 03:17:54|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0| 23147|2021-07-18 03:17:51|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0| 23146|2021-07-18 03:17:48|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0| 23145|2021-07-18 03:17:45|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+
only showing top 5 rows
```

### 3. 스트리밍 처리 ###

배치처리에서는 spark.read 로 데이터를 읽어오지만, 스트리밍 처리에서는 readStream 함수를 이용하여 데이터를 읽어온다.
kafka 메시지 칼럼 중, string 타입의 value 칼럼은 byte array로 메시지가 출력되는데, udf 함수를 이용하여 byte array 를 string 으로 변환한다. 

```
scala> import org.apache.spark.sql.functions.udf

scala> :paste
var kdf = spark.readStream.format("kafka")
	       .option("kafka.bootstrap.servers", "b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092") 
               .option("subscribe", "cpu-metric") 
               .option("startingOffsets", "earliest") 
               .load()  // kdf is kafka data frame

scala> val tostr = udf((payload: Array[Byte]) => new String(payload))
scala> kdf = kdf.withColumn("value", tostr(kdf("value")))

scala> :paste
val stream = kdf.writeStream
	        .outputMode("append")
		.format("console")
		.start()
		.awaitTermination()

// Exiting paste mode, now interpreting.

21/07/18 03:23:58 WARN StreamingQueryManager: Temporary checkpoint location created which is deleted normally when the query didn't fail: /mnt/tmp/temporary-03c63662-bd87-49f7-a76d-5924293c7512. If it's required to delete it under any circumstances, please set spark.sql.streaming.forceDeleteTempCheckpointLocation to true. Important to know deleting temp checkpoint folder is best effort.
21/07/18 03:23:58 WARN StreamingQueryManager: spark.sql.adaptive.enabled is not supported in streaming DataFrames/Datasets and will be disabled.
-------------------------------------------
Batch: 0
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     0|2021-07-17 08:00:24|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     1|2021-07-17 08:00:27|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     2|2021-07-17 08:00:30|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     3|2021-07-17 08:00:33|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     4|2021-07-17 08:00:36|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     5|2021-07-17 08:00:39|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     6|2021-07-17 08:00:42|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     7|2021-07-17 08:00:45|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     8|2021-07-17 08:00:48|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     9|2021-07-17 08:00:51|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    10|2021-07-17 08:00:54|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    11|2021-07-17 08:00:57|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    12|2021-07-17 08:01:00|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    13|2021-07-17 08:01:03|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    14|2021-07-17 08:01:06|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    15|2021-07-17 08:01:09|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    16|2021-07-17 08:01:12|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    17|2021-07-17 08:01:15|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    18|2021-07-17 08:01:18|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    19|2021-07-17 08:01:21|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+
only showing top 20 rows

-------------------------------------------
Batch: 1
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0| 23271|2021-07-18 03:24:03|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0| 23272|2021-07-18 03:24:06|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0| 23273|2021-07-18 03:24:09|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+

-------------------------------------------
Batch: 2
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0| 23274|2021-07-18 03:24:12|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+

-------------------------------------------
Batch: 3
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0| 23275|2021-07-18 03:24:15|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+
```

#### 3-1. 메시지 파싱하기 ####

value 칼럼의 값에서 idle, iowait, user, sys 값만 출력한다. 

```
scala> import org.apache.spark.sql.functions.udf

scala> :paste
var kdf = spark.readStream.format("kafka")
	       .option("kafka.bootstrap.servers", "b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092") 
               .option("subscribe", "cpu-metric") 
               .option("startingOffsets", "earliest") 
               .load()  // kdf is kafka data frame

scala> val tostr = udf((payload: Array[Byte]) => new String(payload))

scala> :paste 
val getMessage = udf (
    (payload: String, name: String) => {
        val token = payload.split(" ")(1)
        val list = token.split(",").toList
        val map = list.map(text => text.split("=")).map(a => a(0) -> a(1)).toMap
        map.get(name)
    }
)    

kdf = kdf.withColumn("value", tostr(kdf("value")))
kdf = kdf.withColumn("idle", getMessage(kdf("value"), lit("usage_idle") ))
kdf = kdf.withColumn("iowait", getMessage(kdf("value"), lit("usage_iowait") ))
kdf = kdf.withColumn("user", getMessage(kdf("value"), lit("usage_user") ))
kdf = kdf.withColumn("sys", getMessage(kdf("value"), lit("usage_system") ))

scala> :paste
val stream = kdf.writeStream
	        .outputMode("append")
		.format("console")
		.start()
		.awaitTermination()

+----+--------------------+----------+---------+------+-------------------+-------------+-----------------+------+------------------+------------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|             idle|iowait|              user|               sys|
+----+--------------------+----------+---------+------+-------------------+-------------+-----------------+------+------------------+------------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     0|2021-07-19 00:28:09|            0| 93.4301958307014|     0| 4.674668351231917|1.8951358180669522|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     1|2021-07-19 00:28:12|            0|94.45139758030898|     0|  3.98414685022942|1.5644555694618403|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     2|2021-07-19 00:28:15|            0|95.68839825036332|     0| 2.770256196625723|1.5413455530097724|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     3|2021-07-19 00:28:18|            0|95.76730608840747|     0|2.7731442869056537|1.4595496246872421|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     4|2021-07-19 00:28:21|            0|91.41845448864846|     0| 6.665278067069425|1.9162674442824656|
+----+--------------------+----------+---------+------+-------------------+-------------+-----------------+------+------------------+------------------+
only showing top 5 rows
```

#### 3-2. 윈도우 함수 실행하기 ####

```
val windowedCounts = kdf.groupBy(
  window($"timestamp", "10 minutes", "5 minutes"),
  $"user"
).max().show(5)
```

## 참고자료 ##

* [트리거, 윈도우, 슬라이딩 ](https://eyeballs.tistory.com/83)


