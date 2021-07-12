### 1. 하둡 클라이언트 설정 ###

* core-site.xml 설정
```
$ ssh -i ~/tf_key_bigdata.pem ec2-user@ec2-13-209-13-30.ap-northeast-2.compute.amazonaws.com

[ec2-user@ip-10-1-1-31 hadoop]$ cd $HADOOP_HOME/etc/hadoop
[ec2-user@ip-10-1-1-31 hadoop]$ vi core-site.xml
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://ec2-3-36-108-41.ap-northeast-2.compute.amazonaws.com:8200</value>
        </property>
</configuration>



```
