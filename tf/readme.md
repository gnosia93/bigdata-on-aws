* 프로비저닝 하는데 약 30분 정도가 소요되며, 대부분의 시간은 MSK 가 차지한다.
* 워크샵 아키텍처 다이어그램 작성 필요.



### instance profile 중복 류 해결 ###

terraform apply 명령어를 이용하여 리소스를 생성하는 도중에, instance-profile 이 이미 존재한다는 에러 메시지가 출력되는 경우, 아래의 명령어를 이용하여 중복되는 인스턴스 프로파일을 수동으로 지워준 후에 리소스를 빌드하면 오류 없이 인프라를 빌드할 수 있습니다. 

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
