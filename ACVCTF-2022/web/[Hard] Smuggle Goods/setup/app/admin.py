#!/usr/bin/python3
import os
import sqlite3
import requests
from time import sleep
from selenium import webdriver
from selenium.webdriver.firefox.options import Options

options = Options()
options.headless = True
driver = webdriver.Firefox(
			options=options,
			executable_path=r'/usr/bin/geckodriver'
			)
r = requests.post(
		'http://localhost:8000/login',
		data={'username':'admin','password':'fCv3sh0Lio4cG'},
		allow_redirects=False
		)
# Open page as admin
cookie = r.headers['Set-Cookie'].split(';')[0].split('=')[1]
driver.get("http://localhost:8000/data")
driver.add_cookie({'name':'session','value':cookie})
driver.get("http://localhost:8000/data")
sleep(10)
driver.close()
driver.quit()
os.system("pkill -f firefox")

# Clean DB records
conn = sqlite3.connect('cell.db')
cur = conn.cursor()
cur.execute("delete from cell where owner='tamayo'")
conn.commit()
conn.close()
