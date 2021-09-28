### 실행방법 ###

```
$ terraform init

$ terraform apply -auto-approve

$ terraform output

$ terraform destroy -auto-approve
```

### instance profile 중복 오류 발생시 해결 방법 ###

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
```

### EMR 프로비저닝 오류 ###

* https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-ranger-troubleshooting-cluster-failed.html
