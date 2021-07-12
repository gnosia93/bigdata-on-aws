* 프로비저닝 하는데 약 30분 정도가 소요되며, 대부분의 시간은 MSK 가 차지한다.
* MSK Security 그룹 조정필요. - done
* ec2 에 hadoop 클라이언트 설치 필요.   - done
* ec2 에서 MSK 테스트 필요.
* 워크샵 아키텍처 다이어그램 작성 필요.
* ec2 에서 hadoop 명령어를 처음에 실행되지 않다가, ssh 로그인 한 후에 실행된다... 왱?



### instance profile 오류 해결 ###

```
$ aws iam get-instance-profile --instance-profile-name bigdata_ec2_profile
{
    "InstanceProfile": {
        "Path": "/",
        "InstanceProfileName": "bigdata_ec2_profile",
        "InstanceProfileId": "AIPAXNB2LVDE7HJSAUBLJ",
        "CreateDate": "2021-07-12T00:03:43Z",
        "Roles": []
    }
}
$ aws iam delete-instance-profile --instance-profile-name bigdata_ec2_profile
$ aws iam get-instance-profile --instance-profile-name bigdata_ec2_profile

An error occurred (NoSuchEntity) when calling the GetInstanceProfile operation: Instance Profile bigdata_ec2_profile cannot be found.

$ aws iam get-instance-profile --instance-profile-name bigdata_emr_profile
{
    "InstanceProfile": {
        "Path": "/",
        "InstanceProfileName": "bigdata_emr_profile",
        "InstanceProfileId": "AIPAXNB2LVDE5DMVIZZMZ",
        "CreateDate": "2021-07-12T00:03:43Z",
        "Roles": []
    }
}
$ aws iam delete-instance-profile --instance-profile-name bigdata_emr_profile
$ aws iam get-instance-profile --instance-profile-name bigdata_emr_profile

An error occurred (NoSuchEntity) when calling the GetInstanceProfile operation: Instance Profile bigdata_emr_profile cannot be found.
```
