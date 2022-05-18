#!/bin/bash
service nginx start
cd /app; python3 app.py
