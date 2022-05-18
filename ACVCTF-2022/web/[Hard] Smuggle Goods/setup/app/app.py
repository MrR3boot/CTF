import uuid
import sqlite3
from flask import *
from functools import wraps

app = Flask(__name__)

app.config['SECRET_KEY'] = uuid.uuid4().hex

def login_required(f):
	@wraps(f)
	def wrap(*args, ** kwargs):
		if session.get('user'):
			return f(*args, ** kwargs)
		else:
			return redirect('/')
	return wrap

@app.route('/')
def index():
	if not session.get('user'):
		return render_template('index.html')
	else:
		return redirect('/home')

@app.route('/login', methods=["POST"])
def login():
	username = request.form.get('username')
	password = request.form.get('password')
	if username=='admin' and password=='fCv3sh0Lio4cG':
		session['user']=username
		return redirect('/home')
	if username=='tamayo' and password=='dCf3VkFt04Ds92S':
		session['user']=username
		return redirect('/home')
	else:
		return render_template('index.html',err='Oops. Those are wrong pair of credentials')

@app.route('/update')
@login_required
def update():
	conn = sqlite3.connect('cell.db')
	cur = conn.cursor()
	cno = request.args.get('cno')
	lid = request.args.get('lid')
	lkey = request.args.get('lkey')
	mark = request.args.get('mark').replace('<','').replace('>','').replace('%3c','').replace('%3e','')
	cur.execute("insert into cell values (?,?,?,?,?)",(cno,lid,lkey,session['user'],mark))
	conn.commit()
	cur.execute("select * from cell")
	r = cur.fetchall()
	msg='Newly created data is  under review'
	return render_template('data.html',result=r,msg=msg)

@app.route('/delete')
@login_required
def delete():
	conn = sqlite3.connect('cell.db')
	cur = conn.cursor()
	cur.execute("delete from cell where cno=? and owner!=?",(request.args.get('cno'),'admin'))
	conn.commit()
	return redirect('/data')

@app.route('/data')
@login_required
def data():
	conn = sqlite3.connect('cell.db')
	cur = conn.cursor()
	cur.execute("select * from cell")
	r = cur.fetchall()
	return render_template('data.html',result=r)

@app.route('/home')
@login_required
def home():
	return render_template('home.html')

app.run('0.0.0.0',port=8000)
