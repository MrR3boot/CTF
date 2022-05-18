FROM lunasec/tomcat-9.0.59-jdk11

# Install deps
RUN apt update && apt install supervisor nginx -y

# Configure tomcat and deploy app
COPY ROOT.war /usr/local/tomcat/webapps/
COPY conf/server.xml /usr/local/tomcat/conf/

# Configure nginx
ADD nginx/certs /etc/nginx/certs
ADD nginx/conf/default /etc/nginx/sites-available/
ADD nginx/www/index.html /var/www/html/
ADD repo/repo.tar /var/www/html/

# Configure supervisord
ADD config/supervisord.conf /etc/

# Expose NGINX port
EXPOSE 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
