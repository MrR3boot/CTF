FROM alpine:latest

RUN apk update && apk add apache2 php7-apache2 php7-mbstring php7-gd php7-xml php7-dom php7-ctype
ADD src /var/www/localhost/htdocs/
ADD flag.txt /
ADD conf/httpd.conf /etc/apache2/httpd.conf
RUN chown apache:apache -R /var/www/localhost/htdocs

CMD [ "httpd", "-D", "FOREGROUND" ]
