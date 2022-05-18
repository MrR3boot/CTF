import os
from flask import *
from Crypto.Cipher import AES


KEY = os.urandom(16)
FLAG = "Palermo: Plan Aikido activated\nProfessor: Roger.\nACVCTF{0mg_1ts_0fb_4nd_0_0_w34k}"

app = Flask(__name__)

@app.route('/encrypt/message/<plaintext>/<iv>/')
def encrypt(plaintext, iv):
    plaintext = bytes.fromhex(plaintext)
    iv = bytes.fromhex(iv)
    if len(iv) != 16:
        return {"error": "IV length must be 16"}

    cipher = AES.new(KEY, AES.MODE_OFB, iv)
    encrypted = cipher.encrypt(plaintext)
    ciphertext = encrypted.hex()

    return {"encrypted_msg": ciphertext}


@app.route('/secret/message/professor')
def encrypt_flag():
    iv = os.urandom(16)

    cipher = AES.new(KEY, AES.MODE_OFB, iv)
    encrypted = cipher.encrypt(FLAG.encode())
    ciphertext = iv.hex() + encrypted.hex()

    return {"encrypted_msg": ciphertext}

@app.route('/')
def index():
	return render_template('index.html')

app.run('0.0.0.0',5000)
