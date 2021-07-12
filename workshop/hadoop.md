테라폼에 의해 생성된 ec2 인스턴스는 하둡 및 카프카용 클라이언트로 사용될 예정이므로, 아래와 같은 설정이 필요합니다. 

### 1. 하둡 클라이언트 설정 ###

테라폼을 이용하여 ec2 인스턴스와 emr 마스터 노드의 DNS 주소를 조회합니다. 
```
$ terraform output
ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
emr_master_public_dns = ec2-3-36-108-41.ap-northeast-2.compute.amazonaws.com
msk_brokers = b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
rds_endpoint = bigdata-postgres.cwhptybasok6.ap-northeast-2.rds.amazonaws.com:5432
```

ec2 인스턴스로 로그인 한 후, 하둡 설정 디렉토리로 이동하여 core-site.xml 파일의 내용을 아래와 같이 수정합니다. 이때
hdfs 주소는 테라폼 Output 값 중 emr_master_public_dns 의 값으로 입력해야 하고, 포트값은 8020 로 설정합니다.   

```
$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
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
                <value>hdfs://ec2-3-36-108-41.ap-northeast-2.compute.amazonaws.com:8020</value>
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

### 2. 카프카 클라이언트 설정 ###


