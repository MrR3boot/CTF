import re
import requests
from flask import *

app = Flask(__name__)

@app.route('/')
def index():
	return render_template('index.html')

@app.route('/api/v2/service/check', methods=['POST'])
def check():
	if request.get_json():
		url = request.get_json()['server']
		try:
			regex = re.compile(r'\b(\w+[.]\w+)')
			check = re.match(regex,url)
			if check:
				return 'Failed to reach the server',501
			r = requests.get(f'http://{url}',allow_redirects=False, timeout=5)
			return r.text,200
		except:
			return 'Failed to reach the server',501

app.run('0.0.0.0',debug=True)