![kafka](https://github.com/gnosia93/bigdata-on-aws/blob/main/workshop/images/kafka-logo.png)

이번 챕터에서는 CPU 사용량 정보를 수집하기 위해서 EC2 인스턴스에 텔레그래프를 설치 한 후, 카프카 토픽으로 EC2의 CPU 사용량 정보를 전송하고, 카프카 콘솔 컨슈머를 이용하여 전송된 메시지를 읽어보는 실습을 하도록 하겠습니다.

### 1. EC2에 telegraf 설치하기 ###

ec2 인스턴스로 로그인하여 telegraf 를 설치합니다. 
```
$ terraform output | grep ec2_pub
ec2_public_ip = "ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com"

$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-3-35-132-185.ap-northeast-2.compute.amazonaws.com
Last login: Sat Jul 17 00:45:23 2021 from 218.238.107.63

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
19 package(s) needed for security, out of 21 available
Run "sudo yum update" to apply all updates.

[ec2-user@ip-10-1-1-31 ~]$ cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL 7
baseurl = https://repos.influxdata.com/rhel/7/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

[ec2-user@ip-10-1-1-31 ~]$ ls -la  /etc/yum.repos.d
합계 24
drwxr-xr-x  2 root root   75  7월 17 07:36 .
drwxr-xr-x 87 root root 8192  7월 12 01:59 ..
-rw-r--r--  1 root root 1003 12월  8  2020 amzn2-core.repo
-rw-r--r--  1 root root 1105  7월  6 17:26 amzn2-extras.repo
-rw-r--r--  1 root root  186  7월 17 07:36 influxdb.repo

[ec2-user@ip-10-1-1-31 ~]$ sudo yum install -y telegraf
```

### 2. telegraf 설정하기 ###

카프카 브로커 주소를 AWS 콘솔 또는 테라폼 명령어를 이용하여 조회한 후, 
```
$ terraform output | grep msk
msk_brokers = "b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092"
```

ec2 인스턴스에 아래의 스크립트를 이용하여 telegraf 설정 파일을 생성합니다. 이때 [[outputs.kafka]] 부분의 brokers 의 주소는 여러분들의 브로커 주소로 대체해야 합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.old

[ec2-user@ip-10-1-1-31 ~]$ sudo cat <<EOF | sudo tee /etc/telegraf/telegraf.conf
[agent]
  interval = "3s"
  flush_interval = "3s"
  
[[outputs.kafka]]
   brokers = [ "b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092", 
               "b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092", 
               "b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092" ]   ## 브로커 주소를 수정해야 합니다. 
   topic = "cpu-metric"

[[inputs.cpu]]
percpu = false
totalcpu = true
#collect_cpu_time = false
report_active = false
EOF

[ec2-user@ip-10-1-1-31 ~]$ 
```

### 3. 카프카 토픽 생성하기 ###

아래와 같이 cpu-metric 이라는 새로운 카프카 토픽을 생성합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ kafka-topics.sh --create --topic cpu-metric --bootstrap-server \
b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092

[ec2-user@ip-10-1-1-31 ~]$ kafka-topics.sh --list --bootstrap-server \
b-1.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-2.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-3.bigdata-msk.4hz3qf.c2.kafka.ap-northeast-2.amazonaws.com:9092

__amazon_msk_canary
__amazon_msk_canary_state
__consumer_offsets
cpu-metric
```


### 4. telegraf 실행하기 ###

telegraf 를 아래와 같이 실행하고, status 옵션을 이용하여 정상 동작여부를 관찰합니다. 

```
[ec2-user@ip-10-1-1-31 ~]$ sudo systemctl start telegraf

[ec2-user@ip-10-1-1-31 ~]$ sudo systemctl status telegraf
● telegraf.service - The plugin-driven server agent for reporting metrics into InfluxDB
   Loaded: loaded (/usr/lib/systemd/system/telegraf.service; enabled; vendor preset: disabled)
   Active: active (running) since 토 2021-07-17 08:00:18 UTC; 3s ago
     Docs: https://github.com/influxdata/telegraf
 Main PID: 8042 (telegraf)
   CGroup: /system.slice/telegraf.service
           └─8042 /usr/bin/telegraf -config /etc/telegraf/telegraf.conf -config-directory /etc/telegraf/telegraf.d

 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal systemd[1]: Started The plugin-driven server agent for reporting metrics into InfluxDB.
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: time="2021-07-17T08:00:18Z" level=error msg="failed to create cache directory. /etc/telegraf/.cache/snowflake, err: mkd...log.go:120"
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: time="2021-07-17T08:00:18Z" level=error msg="failed to open. Ignored. open /etc/telegraf/.cache/snowflake/ocsp_response...log.go:120"
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Starting Telegraf 1.19.1
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Loaded inputs: cpu
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Loaded aggregators:
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Loaded processors:
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Loaded outputs: kafka
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! Tags enabled: host=ip-10-1-1-31.ap-northeast-2.compute.internal
 7월 17 08:00:18 ip-10-1-1-31.ap-northeast-2.compute.internal telegraf[8042]: 2021-07-17T08:00:18Z I! [agent] Config: Interval:3s, Quiet:false, Hostname:"ip-10-1-1-31.ap-northeast-2.compute.interna...Interval:3s
Hint: Some lines were ellipsized, use -l to show in full.
```


### 5. 카프카 메시지 확인 ###

카프카 콘솔 컨슈머 어플리케이션을 이용하여 카프카로 전송 되는 메시지를 확인하도록 합니다. 
정상적인 경우, 아래와 같이 3초에 한번씩 새로운 메시지가 토픽을 통해 전달되는 것을 확인 할 수 있습니다. 

```
[ec2-user@ip-10-1-1-31 ~]$ kafka-console-consumer.sh --topic cpu-metric --bootstrap-server \
b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
cpu,cpu=cpu-total,host=ip-10-1-1-31.ap-northeast-2.compute.internal usage_guest=0,usage_system=0,usage_nice=0,usage_softirq=0,usage_irq=0,usage_steal=0,usage_guest_nice=0,usage_user=0.7506255212831479,usage_idle=99.24937447995991,usage_iowait=0 1626509499000000000

cpu,cpu=cpu-total,host=ip-10-1-1-31.ap-northeast-2.compute.internal usage_user=0.24999999999977263,usage_iowait=0,usage_irq=0,usage_guest=0,usage_guest_nice=0,usage_system=0.08333333333337596,usage_idle=99.66666666635622,usage_nice=0,usage_softirq=0,usage_steal=0 1626509502000000000

cpu,cpu=cpu-total,host=ip-10-1-1-31.ap-northeast-2.compute.internal usage_system=0,usage_idle=99.75020815963434,usage_nice=0,usage_guest=0,usage_steal=0,usage_guest_nice=0,usage_user=0.24979184013280142,usage_iowait=0,usage_irq=0,usage_softirq=0 1626509505000000000
```

## 참고자료 ##

* [아파치 카프카(Apache Kafka) 정의 및 특징](https://twofootdog.tistory.com/86)

* [아파치 카프카 소개](https://pearlluck.tistory.com/288)

* [카프라카 무엇인가?](https://velog.io/@jaehyeong/Apache-Kafka%EC%95%84%ED%8C%8C%EC%B9%98-%EC%B9%B4%ED%94%84%EC%B9%B4%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80)
