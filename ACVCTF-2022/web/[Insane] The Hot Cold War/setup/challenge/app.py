import os, string
from flask import Flask, render_template, render_template_string, request
app = Flask(__name__)

@app.route("/subscribe",methods=["GET"])
def subscribe():
    try:
    	email = request.args.get('email')
    except:
    	return render_template("index.html",q="Email ID is empty")
    blacklist = ["__classes__","request[request.","__","file","write"]
    for bad_string in blacklist:
        if  bad_string in email:
            return render_template("index.html",error="ah! we don't allow these characters")
    for bad_string in blacklist:
        for param in request.args:
            if bad_string in request.args[param]:
                return render_template("index.html",error="ah! we don't allow these characters")
    rendered_template = render_template("index.html", email=email)
    result = render_template_string("{}".format(email))
    return render_template("index.html", email=result)
    
@app.route("/")
def index():
	return render_template("index.html")

if __name__ == "__main__":
    app.run('0.0.0.0',port=80)
