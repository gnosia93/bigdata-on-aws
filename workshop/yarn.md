
### 1. yarn 어플리케이션 리스트 조회 ###
```
[hadoop@ip-10-1-1-136 ~]$ yarn application -list
2021-07-17 02:39:40,107 INFO client.RMProxy: Connecting to ResourceManager at ip-10-1-1-136.ap-northeast-2.compute.internal/10.1.1.136:8032
2021-07-17 02:39:40,294 INFO client.AHSProxy: Connecting to Application History server at ip-10-1-1-136.ap-northeast-2.compute.internal/10.1.1.136:10200
Total number of applications (application-types: [], states: [SUBMITTED, ACCEPTED, RUNNING] and tags: []):3
                Application-Id	    Application-Name	    Application-Type	      User	     Queue	             State	       Final-State	       Progress	                       Tracking-URL
application_1626484111706_0009	HIVE-fa944d87-830d-4f30-b704-80d1a15ec80c	                 TEZ	    hadoop	   default	           RUNNING	         UNDEFINED	             0%	http://ip-10-1-1-19.ap-northeast-2.compute.internal:46459/ui/
application_1626484111706_0011	HIVE-6a3c5c6c-265f-43e4-bab5-a1bc93a78885	                 TEZ	    hadoop	   default	          ACCEPTED	         UNDEFINED	             0%	                                N/A
application_1626484111706_0012	HIVE-6e5833c7-ada2-4d3c-ba19-2e0d53f1dcc5	                 TEZ	    hadoop	   default	          ACCEPTED	         UNDEFINED	             0%	                                N/A
```

### 2. yarn 어플리케이션 kill ###
```
[hadoop@ip-10-1-1-136 ~]$ yarn application -kill application_1626484111706_0009 application_1626484111706_0011
```
