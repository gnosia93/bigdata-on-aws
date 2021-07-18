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
res18: org.apache.spark.sql.DataFrame = [key: binary, value: binary ... 5 more fields]

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
res1: Long = 2356

scala> kdf.sort(desc("timestamp")).show()       // 레코드를 timestamp 의 역순으로 출력합니다. show() 함수의 기본 레코드 건수는 20건 입니다.
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   874|2021-07-17 19:26:48|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   873|2021-07-17 19:26:45|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   872|2021-07-17 19:26:42|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   871|2021-07-17 19:26:39|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   870|2021-07-17 19:26:36|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   869|2021-07-17 19:26:33|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   868|2021-07-17 19:26:30|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   867|2021-07-17 19:26:27|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   866|2021-07-17 19:26:24|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   865|2021-07-17 19:26:21|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   864|2021-07-17 19:26:18|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   863|2021-07-17 19:26:15|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   862|2021-07-17 19:26:12|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   861|2021-07-17 19:26:09|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   860|2021-07-17 19:26:06|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   859|2021-07-17 19:26:03|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   858|2021-07-17 19:26:00|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   857|2021-07-17 19:25:57|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   856|2021-07-17 19:25:54|            0|
|null|[63 70 75 2C 63 7...|cpu-metric|        0|   855|2021-07-17 19:25:51|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+
only showing top 20 rows
```

### 스트리밍 처리 ###

배치처리에서는 spark.read 로 데이터를 읽어오지만, 스트리밍 처리에서는 readStream 함수를 이용하여 데이터를 읽어온다.
kafka 메시지 칼럼 중, string 타입의 value 칼럼은 byte array로 메시지가 출력되는데, udf 함수를 이용하여 byte array 를 string 으로 변환한다. 

```
scala> // import org.apache.spark.sql.streaming.Trigger
scala> import org.apache.spark.sql.functions.udf

scala> :paste
var kdf = spark.readStream.format("kafka")
	       .option("kafka.bootstrap.servers", "localhost:9092") 
               .option("subscribe", "cpu-metric") 
               .option("startingOffsets", "earliest") 
               .load()  // kdf is kafka data frame

scala> val tostr = udf((payload: Array[Byte]) => new String(payload))
scala> kdf = kdf.withColumn("value", tostr(kdf("value")))

scala> :paste
val stream = kdf.writeStream    // .trigger(Trigger.ProcessingTime("1 seconds"))
	        .outputMode("append")
		.format("console")
		.start()
		.awaitTermination()
		

// Exiting paste mode, now interpreting.

2021-07-17 20:35:59,990 WARN streaming.StreamingQueryManager: Temporary checkpoint location created which is deleted normally when the query didn't fail: /private/var/folders/jr/0gpm8d5j0wvg8q6b56tpkfhh701ytj/T/temporary-2c36e37c-a38d-489f-9cbb-158ec00ba9f2. If it's required to delete it under any circumstances, please set spark.sql.streaming.forceDeleteTempCheckpointLocation to true. Important to know deleting temp checkpoint folder is best effort.
-------------------------------------------
Batch: 0
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     0|2021-07-17 18:42:39|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     1|2021-07-17 18:42:42|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     2|2021-07-17 18:42:45|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     3|2021-07-17 18:42:48|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     4|2021-07-17 18:42:51|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     5|2021-07-17 18:42:54|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     6|2021-07-17 18:42:57|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     7|2021-07-17 18:43:00|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     8|2021-07-17 18:43:03|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|     9|2021-07-17 18:43:06|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    10|2021-07-17 18:43:09|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    11|2021-07-17 18:43:12|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    12|2021-07-17 18:43:15|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    13|2021-07-17 18:43:18|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    14|2021-07-17 18:43:21|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    15|2021-07-17 18:43:24|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    16|2021-07-17 18:43:27|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    17|2021-07-17 18:43:30|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    18|2021-07-17 18:43:33|            0|
|null|cpu,cpu=cpu-total...|cpu-metric|        0|    19|2021-07-17 18:43:36|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+
only showing top 20 rows

-------------------------------------------
Batch: 1
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|  2258|2021-07-17 20:36:00|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+

-------------------------------------------
Batch: 2
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|  2259|2021-07-17 20:36:03|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+

-------------------------------------------
Batch: 3
-------------------------------------------
+----+--------------------+----------+---------+------+-------------------+-------------+
| key|               value|     topic|partition|offset|          timestamp|timestampType|
+----+--------------------+----------+---------+------+-------------------+-------------+
|null|cpu,cpu=cpu-total...|cpu-metric|        0|  2260|2021-07-17 20:36:06|            0|
+----+--------------------+----------+---------+------+-------------------+-------------+

```

### value 칼럼 --> object ###
	
  * https://sparkbyexamples.com/spark/spark-streaming-with-kafka/

[메시지 포맷]
```
cpu,                                 
cpu=cpu-total,
host=f8ffc2077dc2.ant.amazon.com 
usage_steal=0,
usage_guest=0,
usage_system=2.1059216013314246,
usage_iowait=0,
usage_irq=0,
usage_softirq=0,
usage_guest_nice=0,
usage_user=3.5029190992441994,
usage_idle=94.39115929929922,
usage_nice=0 1626523194000000000
```


* https://stackoverflow.com/questions/39255973/split-1-column-into-3-columns-in-spark-scala

[칼럼 Tokenize] - 원본 메이시의 엘리먼트간의 순서가 뒤죽박죽이라서.. 순서대로 짤라내진 못하고.. kv 형태로 바꿔야 할듯.. 또한 tokenize 는 comma | space 가 되어야 할듯.

```
scala> val df2 = df.select(substring_index(col("value"), ",", -10).as("b"))
df2: org.apache.spark.sql.DataFrame = [b: string]


scala> import spark.implicits._
import spark.implicits._

scala> import org.apache.spark.sql.functions.split
import org.apache.spark.sql.functions.split


withColumn("col1", split(col("text"), "\\.").getItem(0))
  .withColumn("col2", split(col("text"), "\\.").getItem(1))
  .withColumn("col3", split(col("text"), "\\.").getItem(2))


scala> val df2 = df.withColumn("idle",   split($"value", ",").getItem(4))
		   
		   
     		     	$"_tmp".getItem(2).as("host"),
		//	$"_tmp".getItem(3).as("usage_steal"),
		//	$"_tmp".getItem(4).as("usage_guest"),
			$"_tmp".getItem(5).as("usage_system"),
			$"_tmp".getItem(6).as("usage_iowait"),
		//	$"_tmp".getItem(7).as("usage_irq"),
		//	$"_tmp".getItem(8).as("usage_softirq"),
		//	$"_tmp".getItem(9).as("usage_guest_nice"),
			$"_tmp".getItem(10).as("usage_user"),
			$"_tmp".getItem(11).as("usage_idle"),
		//	$"_tmp".getItem(12).as("usage_nice"),
		   )

scala> df2.show()
```


### windowing 함수 태우기 ###


## 참고자료 ##

* [java.lang.IllegalArgumentException: Required executor memory (4743 MB), offHeap memory (0) MB, overhead (889 MB), and PySpark memory (0 MB) is above the max threshold (3072 MB) of this cluster! Please check the values of 'yarn.scheduler.maximum-allocation-mb' and/or 'yarn.nodemanager.resource.memory-mb'.)](https://m.blog.naver.com/gyrbsdl18/220594197752)
