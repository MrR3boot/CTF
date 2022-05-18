# TKO

## Description



## Setup

We're provided with two files. 

```bash
file *
flag.enc: data
pub_key:  ASCII text
```

`flag.enc` is encrypted data. 

```bash
cat flag.enc | xxd
00000000: 849c c23d 4fc1 4b2d 5d7f 4394 a4a8 0dcf  ...=O.K-].C.....
00000010: 06df 578f d56b 4e29 3323 4d1e b0c6 a111  ..W..kN)3#M.....
```

We've a `pub_key` file which is a RSA public key.

```bash
-----BEGIN PUBLIC KEY-----
MDwwDQYJKoZIhvcNAQEBBQADKwAwKAIhANbpz/4fUpMRD10S8QFcpNhfY00XQKEx
tpqSs1txwcB5AgMBAAE=
-----END PUBLIC KEY-----
```

Using `openssl` we can view the information of this key.

```bash
openssl rsa -noout -text -in pub_key -pubin
RSA Public-Key: (256 bit)
Modulus:
    00:d6:e9:cf:fe:1f:52:93:11:0f:5d:12:f1:01:5c:
    a4:d8:5f:63:4d:17:40:a1:31:b6:9a:92:b3:5b:71:
    c1:c0:79
Exponent: 65537 (0x10001)
```

Bit size is `256` which is very weak. It also shows the Exponent `e` value which is 65537. 

```bash
openssl rsautl -decrypt -inkey pub_key -pubin -in flag.enc 
A private key is needed for this operation
```

It is clear that we have to extract private key in order to decrypt the given file. This can be manually by extracting modulus value and finding primes. A tool like [RsaCtfTool](https://github.com/Ganapati/RsaCtfTool) can also be used to automate these techniques.

```bash
./RsaCtfTool.py --publickey pub_key --uncipherfile flag.enc 
private argument is not set, the private key will not be displayed, even if recovered.

[*] Testing key pub_key.
[*] Performing factordb attack on pub_key.
[*] Attack success with factordb method !

Results for pub_key:

Unciphered data :
HEX : 0x000239a6f2735a99d679004143564354467b7733346b6d3064756c303a287d0a
INT (big endian) : 3931594555499007694483293539848052603836472855486556345190315067385085194
INT (little endian) : 4744262007560347506006965446586576110142491804074231116655777098372054843904
utf-16 : Ȁ꘹珲饚秖䄀噃呃筆㍷欴ね畤ぬ⠺੽
STR : b'\x00\x029\xa6\xf2sZ\x99\xd6y\x00ACVCTF{w34km0dul0:(}\n'
```

In string format we read the flag `ACVCTF{w34km0dul0:(}`. 

Below is manual approach for crypto lovers :muscle:

So here is the theory to solve this challenge manually. 

* Public key contains `n` and `e`.
* Private key contains `d` and `n` where `d` is private exponent

In order to calculate `d` we have to find factors of `n`. Let's extract `n` and `e` from public key.

```python
from Crypto.PublicKey import RSA
key = RSA.importKey(open('pub_key','r'))
n = key.n # 97208060475531259975781092169870495554522959999780547583681051436586442539129
e = key.e # 65537
```

We can try to find factors for `n` from factordb.

```python
import requests
import json
r = requests.get(f'http://factordb.com/api/?query={n}')
factors = json.loads(r.text)['factors']
p = int(factors[0][0])
q = int(factors[0][1])
```

Let's calculate private exponent. 

```bash
""" Modular inverse """
def egcd(a, b):
    x,y, u,v = 0,1, 1,0
    while a != 0:
        q, r = b//a, b%a
        m, n = x-u*q, y-v*q
        b,a, x,y, u,v = a,r, u,v, m,n
        gcd = b
    return gcd, x, y
   
phi = (p - 1) * (q - 1)
gcd, a, b = egcd(e, phi)
d = a #30749352300505646437247933560791388731981666765098354744119404091033582646461
```

Having `n, e, d,` we can construct private key.

```python
from Crypto.PublicKey import RSA
key = RSA.construct((n,e,d,p,q))
key.exportKey()

"""
b'-----BEGIN RSA PRIVATE KEY-----\nMIGqAgEAAiEA1unP/h9SkxEPXRLxAVyk2F9jTRdAoTG2mpKzW3HBwHkCAwEAAQIg\nQ/uEQtOvsDvWS0/hkte2gPL89/XgahXPV0RP9/QZNL0CEQDjlu+8+4+4duJL4Wqg\n+usPAhEA8b3IElWRCFCvmY2cvru79wIQKJQP2K0tueEQhiEB5wP2BwIRANKOxgRK\nKWA/vyOVODDdnjMCEF5vp3/IfKARg+BbghOcGNU=\n-----END RSA PRIVATE KEY-----'
"""
```

We replace new lines and save it as `private`. Flag is can be decrypted now.

```bash
openssl rsautl --decrypt -inkey private -in flag.enc 
ACVCTF{w34km0dul0:(}
```



