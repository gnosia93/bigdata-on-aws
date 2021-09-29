![hadoop](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/hadoop-1.png)

테라폼에 의해 생성된 ec2 인스턴스는 하둡 및 카프카용 클라이언트로 사용됩니다. 각각의 클러스터가 정상적으로 동작하는지 아래의 명령어를 이용하여 테스트 합니다.  

### 1. 하둡 테스트 ###

테라폼을 이용하여 ec2 인스턴스와 emr 마스터 노드의 DNS 주소를 조회합니다. 
```
$ terraform output

airflow_public_ip = "ec2-52-79-178-219.ap-northeast-2.compute.amazonaws.com"
ec2_public_ip = "ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com"
emr_master_public_dns = "ec2-3-36-96-133.ap-northeast-2.compute.amazonaws.com"
msk_brokers = "b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092"
rds_endpoint = "bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432"
```

ec2 인스턴스로 로그인 한 후, 하둡 설정 디렉토리로 이동하여 core-site.xml 파일의 내용을 아래와 같이 수정합니다. 이때
hdfs 주소는 테라폼 Output 값 중 emr_master_public_dns 의 값으로 입력해야 하고, 포트값은 8020 로 설정합니다.   

```
$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/

[ec2-user@ip-10-1-1-31 hadoop]$ cd $HADOOP_HOME/etc/hadoop
[ec2-user@ip-10-1-1-31 hadoop]$ vi core-site.xml
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://ec2-3-36-96-133.ap-northeast-2.compute.amazonaws.com:8020</value>
        </property>
</configuration>
```

core-site.xml 설정을 완료한 후 hadoop 명령어를 이용하여 hdfs 를 조회합니다. 이때 설정에 오류가 없는 경우 아래와 같은 디렉토리 출력될 것입니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ hadoop fs -ls /
Found 4 items
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /apps
drwxrwxrwt   - hdfs hdfsadmingroup          0 2021-07-12 02:08 /tmp
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /user
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /var
```

### 2. 카프카 테스트 ###

아래 스크립트에서 bootstrap-server 의 주소는 terraform output 결과값 중 msk_brokers 에 해당 합니다. 

* 토픽생성 (test 토픽)

kafka-topics.sh --create 명령어를 이용하여 메시지를 수신할 test 토픽을 아래와 같이 생성합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ kafka-topics.sh --create --replication-factor 3 --partitions 3 --topic test \
--bootstrap-server b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092
Created topic test.
```

* 토픽조회
```
[ec2-user@ip-10-1-1-31 ~]$ kafka-topics.sh --list \
--bootstrap-server b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092

__amazon_msk_canary
__amazon_msk_canary_state
__consumer_offsets
test
```

* 프로듀서

아래와 같이 콘솔 프로듀서를 이용하여 test 토픽에 메시지를 전송합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ kafka-console-producer.sh --topic test \
--bootstrap-server b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092
>1
>2
>3
>4
>5
>
```

* 컨슈머

별도의 콘솔을 띄워 ec2 인스턴스로 로그인 한 후, 콘솔 컨슈머를 이용하여 test 토픽으로 부터 메시지를 받아옵니다. 
```
$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com
Last login: Mon Jul 12 02:47:04 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/

[ec2-user@ip-10-1-1-31 ~]$ kafka-console-consumer.sh --topic test --from-beginning \
--bootstrap-server b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092
2
1
3
4
5
```

* 토픽삭제

테스트 완료 후, 생성한 토픽을 삭제합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ kafka-topics.sh --delete --topic test \
--bootstrap-server b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,\
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092
```

## 참고자료 ##

* [카프카 파티션/replication](https://engkimbs.tistory.com/691)
