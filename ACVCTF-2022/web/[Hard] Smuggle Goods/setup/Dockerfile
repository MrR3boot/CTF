FROM ubuntu:latest

# Install deps
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y nginx python3 python3-pip git firefox supervisor
RUN pip3 install flask pysqlite3 selenium requests
COPY go.tar.gz /root/
RUN tar -C /usr/bin -xzf /root/go.tar.gz
RUN /usr/bin/go/bin/go get golang.org/x/text/secure/bidirule
RUN /usr/bin/go/bin/go get golang.org/x/net/http2/h2c

# Configure Nginx & Go App
COPY conf/nginx.conf /etc/nginx/
RUN mkdir /etc/nginx/ssl
ADD certs/ /etc/nginx/ssl
COPY main.go /root/

# Configure python app
COPY app /app/
COPY start.sh /root/
COPY geckodriver /usr/bin/
RUN chmod +x /usr/bin/geckodriver
COPY bot.sh /root/
RUN chmod +x /root/bot.sh /app/admin.py /root/start.sh

# Configure supervisor
ADD config/supervisord.conf /etc/

EXPOSE 80

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
