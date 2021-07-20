%spark
// 하둡에서 json 파일을읽어 데이터프레임으로 변환
val df = spark.read.format("csv")
    .load("hdfs://ec2-13-125-218-93.ap-northeast-2.compute.amazonaws.com:8020/tmp/airflow/part-m-00000")         // hdfs URL을 emr 마스터 주소로 바꾸세요.
    .toDF("code", "message", "date")

df.groupBy("code").count()
  .filter($"count" >= 100000)
  .orderBy(desc("count"))
  .show(5)

println("rows :" + df.count())    
df.show(10, truncate=false)  
