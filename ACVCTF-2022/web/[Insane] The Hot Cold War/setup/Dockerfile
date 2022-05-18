FROM alpine:latest

# Install deps
RUN apk add python3 py3-pip
RUN pip3 install flask

# Configure app
RUN mkdir /app
WORKDIR /app
COPY challenge /app/
COPY flag.txt /

# Expose http
EXPOSE 80

CMD [ "python3", "app.py" ]

