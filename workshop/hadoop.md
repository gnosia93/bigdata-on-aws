### 1. 하둡 클라이언트 설정 ###

ec2 인스턴스로 로그인 하여 core-site.xml 파일의 내용을 아래와 같이 설정합니다. 이때  

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

[ec2-user@ip-10-1-1-31 ~]$ hadoop fs -ls /
Found 4 items
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /apps
drwxrwxrwt   - hdfs hdfsadmingroup          0 2021-07-12 02:08 /tmp
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /user
drwxr-xr-x   - hdfs hdfsadmingroup          0 2021-07-12 02:05 /var


```
