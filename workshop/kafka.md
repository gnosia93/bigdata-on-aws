이번 챕터에서는 CPU 사용량 정보를 수집하기 위해서 EC2 인스턴스에 텔레그래프를 설치 한 후, 카프카 토픽으로 CPU 사용량 정보를 전송하고, 카프카의 콘솔 컨슈머를 이용하여 전송된 메시지를 읽어보는 실습을 하겠습니다.

### 1. 텔레그래프 설치 ###

ec2 인스턴스로 로그인하여 telegraf 를 설치합니다. 
```
$ terraform output | grep ec2_pub
ec2_public_ip = ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com

$ ssh -i ~/.ssh/tf_key ec2-user@ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com
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
msk_brokers = b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092,b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
```

아래 스크립트를 이용하여 telegraf 용 설정 파일을 생성합니다. 이때 [[outputs.kafka]] 부분의 brokers 의 주소는 여러분들의 브로커 주소로 대체해야 합니다. 
```
[ec2-user@ip-10-1-1-31 ~]$ sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.old

[ec2-user@ip-10-1-1-31 ~]$ sudo cat <<EOF | sudo tee /etc/telegraf/telegraf.conf
[agent]
  interval = "3s"
  flush_interval = "3s"
  
[[outputs.kafka]]
   brokers = [ "b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092", 
               "b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092", 
               "b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092" ]   ## 브로커 주소를 수정해야 합니다. 
   topic = "cpu-metric"

[[inputs.cpu]]
percpu = false
totalcpu = true
#collect_cpu_time = false
report_active = false
EOF

[ec2-user@ip-10-1-1-31 ~]$ 
```

### 3. telegraf 실행하기 ###

systemctl 을 이용하여 telegraf를 실행한 후, 정상적으로 동작하는 지 status 옵션을 이용하여 확인합니다. 

```
[ec2-user@ip-10-1-1-31 ~]$ suso systemctl start telegraf

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

### 4. 카프카 토픽 확인 하기 ###

```
[ec2-user@ip-10-1-1-31 bin]$ ./kafka-topics.sh --list --bootstrap-server \
b-1.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-2.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092, \
b-3.bigdata-msk.w8k9q9.c2.kafka.ap-northeast-2.amazonaws.com:9092
```
